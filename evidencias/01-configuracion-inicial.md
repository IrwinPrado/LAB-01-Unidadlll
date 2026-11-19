# Evidencia 01: Configuración Inicial de Registro

**Estudiante:** Irwin Gabriel Martinez Prado  
**Actividad:** Actividad 1 — Revisar la configuración de registro por defecto  

---

## 1. Comando Ejecutado
```sql
SELECT name, setting, source FROM pg_settings
WHERE name IN ('log_destination', 'logging_collector', 'log_directory', 'log_filename',
'log_connections', 'log_disconnections', 'log_line_prefix',
'log_statement', 'log_min_error_statement', 'log_timezone') ORDER BY name;

```markdown

2. Resultado Obtenido
En la instalación nativa de PostgreSQL 16 sobre Windows, los parámetros de auditoría de conexiones y sentencias vienen desactivados por defecto (log_connections = off, log_disconnections = off, log_statement = none), mientras que el colector (logging_collector = on) viene habilitado por el instalador de EDB.

3. Respuestas
Con esta configuración, ¿se registra quién se conecta?

No. El parámetro log_connections está en off, por lo que las conexiones exitosas no generan registro en la bitácora.

¿Se registran las sentencias UPDATE?

No. El parámetro log_statement está configurado en none, lo que omite el registro de sentencias DML (INSERT, UPDATE, DELETE) y DDL.

¿La línea de bitácora incluye el usuario o la dirección IP del cliente?

No. El formato por defecto (%m [%p]) solo registra la fecha/hora y el identificador de proceso (PID), omitiendo %u (usuario), %d (base de datos) y %h (IP del cliente).

¿En qué zona horaria se registran los eventos? ¿Por qué importa al reconstruir una cronología?

Se registran en UTC/GMT (America/Mazatlan o GMT según configuración del SO). Es fundamental conocerla para correlacionar eventos con otras bitácoras (aplicación, firewall, sistema operativo) sin desfases horarios durante una investigación forense.

Con logging_collector = off, ¿quién decide dónde termina la bitácora: PostgreSQL o el mecanismo con que se desplegó el servidor?

Lo decide el mecanismo de despliegue (el gestor de servicios del sistema operativo, systemd, Homebrew o el motor de contenedores), ya que PostgreSQL simplemente envía los mensajes a stderr.