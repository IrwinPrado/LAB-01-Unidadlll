# Evidencia 15: Reconstrucción de Cronología y Respuestas a Dirección

**Estudiante:** Irwin Gabriel Martinez Prado  
**Actividad:** Actividad 17 — Reconstruir la cronología y responder a Dirección  

---

## 1. Cronología de Eventos Reconstruida

| # | Fecha y hora | Usuario | Cliente | Tipo de evento | Qué ocurrió | ¿Exitoso? | Fuente (bitácora / auditoría) |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | 2026-11-19 (Inicio) | `postgres` | `127.0.0.1` / `::1` | Datos | Incidente inicial: `app_ventas` actualiza RFC de María García (`id=3`) a `GAMA780912XXX` sin bitácora activa. | Sí | Hueco en bitácora (sin registro)[cite: 19] |
| 2 | 2026-11-19 05:55:32 GMT | `postgres` | `::1` | Configuración | Se activan `log_connections`, `log_disconnections`, `log_line_prefix` y `log_statement = 'ddl'`[cite: 20]. | Sí | `dba.bitacora` (PID 15480) |
| 3 | 2026-11-19 (Act. 5) | `app_ventas` | `127.0.0.1` | Acceso | Intento de acceso fallido por contraseña incorrecta (`FATAL: password authentication failed`)[cite: 22]. | No | `dba.bitacora` (`pg_hba.conf` scram-sha-256) |
| 4 | 2026-11-19 (Act. 5) | `usuario_inexistente` | `127.0.0.1` | Acceso | Intento de acceso fallido con rol inexistente (`Role does not exist`)[cite: 22]. | No | `dba.bitacora` (`FATAL`) |
| 5 | 2026-11-19 05:57:32 GMT | `postgres` | `::1` | Privilegio | Ejecución de `REVOKE UPDATE ON clientes FROM soporte_ana` y `GRANT UPDATE ON clientes TO app_ventas`[cite: 24]. | Sí | `dba.bitacora` (PID 15480) |
| 6 | 2026-11-19 05:57:32 GMT | `postgres` | `::1` | Estructura | Se agrega columna `segmento VARCHAR(20)` a `clientes` (`ALTER TABLE`)[cite: 24]. | Sí | `dba.bitacora` (PID 15480) |
| 7 | 2026-11-19 (Act. 7) | `app_ventas` | `127.0.0.1` | Datos | Con `log_statement = 'mod'`, `app_ventas` actualiza teléfono de `id=3` a `6679990000`[cite: 25, 26]. | Sí | `dba.bitacora` (`statement: UPDATE`) |
| 8 | 2026-11-19 (Act. 8) | `soporte_ana` | `127.0.0.1` | Error | Intento rechazado de eliminar cliente (`DELETE FROM clientes WHERE id = 5`)[cite: 27]. | No | `dba.bitacora` (`ERROR: permission denied`) |
| 9 | 2026-11-19 (Act. 12) | `app_ventas` | `127.0.0.1` | Datos | `app_ventas` modifica RFC de `id=3` de `GAMA780912XYZ` a `GAMA780912ZZZ`[cite: 32]. | Sí | `auditoria.cambios_clientes` (`id_evento = 1`) |
| 10 | 2026-11-19 (Act. 13) | `postgres` | local | Datos | Alta y baja de `Pedro Ruiz` (`id=6`) conservando respaldo `JSONB` antes y después[cite: 34, 35]. | Sí | `auditoria.cambios_clientes` (`id_evento = 2, 3`) |
| 11 | 2026-11-19 (Act. 14) | `postgres` | local | Estructura / Datos | Desactivación temporal de `trg_auditoria_clientes`, restauración de RFC a `GAMA780912GHI` y reactivación[cite: 35, 36]. | Sí | `dba.bitacora` (`DISABLE/ENABLE TRIGGER`) |

---

## 2. Respuestas Oficiales a Dirección

1. **¿Quién cambió el RFC la primera vez (Actividad 3)? ¿Y en las Actividades 7, 12 y 14?**
   * **Actividad 3:** **No hay evidencia.** En ese momento `log_statement` estaba en `none` y `log_connections` en `off`, por lo que el motor no dejó rastro del usuario ni de la sesión que ejecutó el `UPDATE`[cite: 19].
   * **Actividad 7:** El rol **`app_ventas`** desde `127.0.0.1` usando `application_name = app-ventas-web` (registrado en `dba.bitacora` gracias a `log_statement = 'mod'`)[cite: 25, 26].
   * **Actividad 12:** El rol **`app_ventas`** desde `127.0.0.1` con `application_name = app-ventas-web` (registrado tanto en `dba.bitacora` como en `auditoria.cambios_clientes`, `id_evento = 1`)[cite: 32, 33].
   * **Actividad 14:** El superusuario **`postgres`** desde conexión local, tras desactivar temporalmente el disparador `trg_auditoria_clientes` (evidencia registrada en `dba.bitacora`, ausente en `auditoria.cambios_clientes` por la desactivación)[cite: 35, 36].

2. **¿Quién cambió el teléfono?**
   * El rol **`app_ventas`** desde la IP `127.0.0.1` mediante la aplicación `app-ventas-web` (`UPDATE clientes SET telefono = '6679990000' WHERE id = 3`), registrado en `dba.bitacora` al tener activo `log_statement = 'mod'`[cite: 26].

3. **¿Hubo intentos de acceso fallidos? ¿De qué usuarios y desde dónde?**
   * **Sí.** Se registraron múltiples intentos fallidos (`FATAL: password authentication failed`) desde **`127.0.0.1`** para el rol **`app_ventas`** (contraseña incorrecta) y para el rol **`usuario_inexistente`** (rol no registrado en el servidor)[cite: 22].

4. **¿Qué valor tenía el RFC antes de cada cambio?**
   * **Antes de la Actividad 3:** **No hay evidencia en bitácora ni tabla de auditoría** (el disparador aún no existía; solo se conoce por los datos iniciales que era `GAMA780912GHI`)[cite: 14, 19].
   * **Antes de la Actividad 7:** **No hay evidencia registrada del valor previo**, pues `log_statement = 'mod'` solo guarda la sentencia SQL ejecutada y el disparador aún no estaba creado[cite: 26].
   * **Antes de la Actividad 12:** El RFC anterior era **`GAMA780912XYZ`**, demostrado con certeza en la columna `valores_antes` (`JSONB`) de `auditoria.cambios_clientes` (`id_evento = 1`)[cite: 33, 34].
   * **Antes de la Actividad 14:** **No hay evidencia en la tabla de auditoría** porque el disparador estaba deshabilitado (`DISABLE TRIGGER`); sin embargo, al correlacionar con `id_evento = 1` de `auditoria.cambios_clientes`, se deduce que el valor vigente previo era `GAMA780912ZZZ`[cite: 33, 35].