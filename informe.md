# Informe Técnico — LAB-01: Bitácoras y Auditoría del Dato en PostgreSQL

**Materia:** Gestión de Seguridad y Desempeño de Bases de Datos  
**Unidad:** III — Auditoría, trazabilidad y gobierno práctico de datos  
**Estudiante:** Irwin Gabriel Martinez Prado  
**Motor:** PostgreSQL 16 (Instalación nativa en Windows)  

---

## 1. Despliegue y Situación Inicial
El laboratorio se ejecutó sobre una instalación nativa de **PostgreSQL 16** en Windows sobre la base de datos `comercial`. Inicialmente, aunque el colector (`logging_collector`) estaba habilitado por el instalador, los parámetros `log_connections`, `log_disconnections` y `log_statement` se encontraban desactivados (`off` / `none`), y `log_line_prefix` únicamente registraba fecha y PID (`%m [%p]`)[cite: 15]. Con esta configuración fue imposible responder a Dirección tras la modificación no rastreada del RFC de María García (`id = 3`), demostrando que el control de acceso regula quién *puede* operar, pero sin auditoría activa previa no existe evidencia de quién *realizó* una acción[cite: 3, 19].

## 2. Configuración Aplicada
Mediante `ALTER SYSTEM` se modificó `postgresql.auto.conf`[cite: 6, 20]:
* `logging_collector = on` (requiere reinicio de servicio en caso de estar en `off`)[cite: 5, 17].
* `log_connections = on` y `log_disconnections = on` (requieren recarga con `pg_reload_conf()`, aplican a nuevas sesiones)[cite: 5, 20].
* `log_line_prefix = '%m [%p] user=%u db=%d app=%a client=%h '` (requiere recarga; identifica actor, base, aplicación e IP)[cite: 5, 20].
* `log_statement = 'mod'` (requiere recarga; registra sentencias DDL, DCL y DML de escritura sin saturar con `SELECT`)[cite: 5, 6, 25].

## 3. Eventos Observados
Se generaron y verificaron los seis tipos de eventos auditables mediante la vista restringida `dba.bitacora`:
* **Acceso:** Conexiones exitosas (`scram-sha-256`) y fallidas (`FATAL`) desde `127.0.0.1`[cite: 22, 23].
* **Privilegio:** Sentencias `GRANT` y `REVOKE` capturadas desde nivel `ddl`[cite: 6, 24].
* **Estructura:** Alteraciones de esquema (`ALTER TABLE clientes ADD COLUMN segmento`)[cite: 24].
* **Datos:** Sentencias `UPDATE` capturadas al elevar `log_statement` a `'mod'`[cite: 25, 26].
* **Error:** Rechazos por falta de permisos (`ERROR: permission denied`) y dependencias (`DROP ROLE`) capturados por `log_min_error_statement = error`[cite: 27].
* **Configuración:** Registro automático en el proceso maestro (`parameter "..." changed to "..."`) tras `pg_reload_conf()`[cite: 21].

## 4. Auditoría del Dato
Para conservar los valores previos y posteriores de cada fila modificada, se creó el esquema aislado `auditoria` (sin permisos para `PUBLIC`) y la tabla `auditoria.cambios_clientes` con columnas `JSONB` (`valores_antes`, `valores_despues`)[cite: 29, 30]. El disparador `trg_auditoria_clientes` ejecuta la función `auditoria.registrar_cambio_cliente()` definida con **`SECURITY DEFINER`** y `SET search_path = pg_catalog, public`[cite: 31, 32]. Esto permite que `app_ventas` dispare el registro de auditoría sin tener permisos directos de lectura o escritura sobre el esquema `auditoria`[cite: 8, 32]. Asimismo, se utilizó **`session_user`** en lugar de `current_user` para registrar el rol real autenticado (`app_ventas`) y no al propietario de la función (`postgres`)[cite: 8, 33].

## 5. Limitaciones
* **Lecturas (`SELECT`):** Ni los disparadores DML ni `log_statement = 'mod'` registran consultas de lectura sobre columnas sensibles como el RFC[cite: 37].
* **Volumen:** Un `UPDATE` masivo sin `WHERE` genera una sola línea en la bitácora de sentencias, pero inserta una fila `JSONB` completa por cada registro afectado en `auditoria.cambios_clientes`[cite: 7, 37].
* **Administrador con control total:** Un superusuario (`postgres`) puede desactivar el disparador (`DISABLE TRIGGER`) o alterar `log_statement = 'none'`, dejando puntos ciegos si no existe separación de funciones ni envío de logs a un servidor externo[cite: 36].

## 6. Riesgos de la Bitácora
* **Exposición de secretos:** Ejecutar `CREATE ROLE ... PASSWORD '...'` con `log_statement` activo escribe la contraseña en texto claro en la bitácora (mitigado usando `\password` y sanitizando con `<REDACTED>` antes de exportar)[cite: 15, 24, 25, 39].
* **Pérdida y acceso indebido:** Conservar bitácoras únicamente en el servidor local las expone a rotación, borrado accidental o acceso no autorizado; por ello se exportó `bitacora-lab01.log` y se generó su resumen criptográfico `SHA-256` (`bitacora-lab01.sha256`) como control de integridad.

## 7. Cronología y Conclusión
Con la combinación de bitácora del servidor (`log_statement = 'mod'` + prefijo completo) y auditoría a nivel de dato mediante disparador `JSONB`, **sí es posible demostrar con certeza quién modificó un dato sensible, cuándo, desde qué IP y qué valor tenía exactamente antes del cambio** (como se comprobó en la Actividad 12 al rastrear el cambio de `GAMA780912XYZ` a `GAMA780912ZZZ`), siempre que dichos mecanismos estén configurados antes del incidente[cite: 19, 33, 34].

---

## 8. Preguntas de Reflexión
1. **¿Por qué la auditoría no puede configurarse después de un incidente para investigarlo?**  
   Porque las bitácoras y disparadores registran eventos en tiempo real conforme ocurren; la información no capturada en ese instante no se almacena en el motor y no puede reconstruirse retroactivamente[cite: 19].
2. **¿Por qué conviene que la bitácora la administre el propio servidor y no el mecanismo de despliegue?**  
   Porque `logging_collector` estandariza la ubicación, rotación y lectura SQL (`pg_current_logfile()`, `pg_read_file()`) independientemente del sistema operativo o contenedor, evitando que la evidencia dependa de scripts externos o se pierda al recrear un contenedor[cite: 4, 5, 39].
3. **¿Por qué el prefijo de línea es tan importante como el nivel de `log_statement`?**  
   Porque `log_statement` registra *qué* consulta se ejecutó, pero sin `%u`, `%d`, `%a` y `%h` en `log_line_prefix` resulta imposible saber *quién*, en qué base, con qué aplicación y desde qué dirección IP la ejecutó[cite: 6].
4. **¿Qué diferencia práctica hay entre registrar la sentencia y registrar el cambio en el dato?**  
   Registrar la sentencia guarda el comando SQL ejecutado (útil para ver intención y consultas masivas), mientras que registrar el cambio en el dato (`OLD`/`NEW`) guarda el estado exacto antes y después de cada fila afectada, permitiendo revertir modificaciones con certeza[cite: 7, 26].
5. **¿Qué evidencia ofrece `pg_stat_activity` que no ofrece la bitácora, y viceversa?**  
   `pg_stat_activity` ofrece una fotografía en tiempo real de las sesiones activas, bloqueos y consultas en curso en ese instante[cite: 7, 28]; la bitácora conserva el historial cronológico persistente de eventos pasados una vez que las sesiones terminan[cite: 7, 28].
6. **Si el administrador puede cambiar `log_statement` a `none` y desactivar el disparador, ¿quién audita al administrador?**  
   Un área externa de Seguridad de la Información / Auditoría Interna mediante el envío inmediato de logs en tiempo real a un servidor remoto (SIEM/Syslog de solo escritura), controles de integridad con hashes fuera del servidor y políticas organizacionales de separación de funciones[cite: 36, 40].