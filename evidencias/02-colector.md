# Evidencia 02: Activación del Colector y Vista de Bitácora

**Estudiante:** Irwin Gabriel Martinez Prado  
**Actividad:** Actividad 2 — Que el servidor administre su propia bitácora  

---

## 1. Comandos Ejecutados
```sql
ALTER SYSTEM SET logging_collector = on;
SELECT pg_current_logfile();

CREATE SCHEMA dba;
REVOKE ALL ON SCHEMA dba FROM PUBLIC;
CREATE VIEW dba.bitacora AS ...

```markdown

2. Resultado Obtenido
El servidor escribe su bitácora activa dentro del directorio log/ en el directorio de datos de PostgreSQL, accesible directamente desde SQL mediante la vista dba.bitacora.

3. Respuestas
¿Por qué logging_collector requiere reinicio y log_statement solo recarga?

Porque logging_collector lanza un proceso secundario dedicado a capturar el flujo stderr desde el arranque del servidor (postmaster), mientras que log_statement es solo un filtro de evaluación de consultas que cada sesión activa puede actualizar al recargar la configuración (pg_reload_conf()).

¿Qué ventaja tiene que la bitácora se lea con SQL y no con una herramienta del sistema operativo o del contenedor? ¿Qué riesgo introduce?

Ventaja: Permite consultar, filtrar y estructurar eventos desde cualquier cliente SQL sin depender de acceso SSH, consola de contenedor ni permisos sobre el sistema de archivos del servidor.

Riesgo: La función pg_read_file() permite leer cualquier archivo al que tenga acceso el usuario del sistema operativo postgres, por lo que otorgar acceso indebido a esta vista o función podría exponer archivos sensibles del servidor.

¿Quién debería poder consultar dba.bitacora?

Únicamente los administradores de bases de datos (DBA) y los roles explícitamente autorizados para auditoría de seguridad, nunca roles de aplicación ni PUBLIC.