# Evidencia 04: Configuración de Bitácora (Conexiones, Prefijo y DDL)

**Estudiante:** Irwin Gabriel Martinez Prado  
**Actividad:** Actividad 4 — Configurar la bitácora  

---

## 1. Comandos Ejecutados
```sql
ALTER SYSTEM SET log_connections = on;
ALTER SYSTEM SET log_disconnections = on;
ALTER SYSTEM SET log_line_prefix = '%m [%p] user=%u db=%d app=%a client=%h ';
ALTER SYSTEM SET log_statement = 'ddl';
SELECT pg_reload_conf();

```markdown

2. Resultado Obtenido
Los parámetros quedaron almacenados en postgresql.auto.conf y activos mediante pg_reload_conf(). La bitácora comenzó a registrar los cambios de parámetros realizados por el proceso principal del servidor y a incluir usuario, base de datos, aplicación y dirección IP en cada línea.

3. Respuestas
¿Por qué el proceso que registra el cambio es el principal y no tu sesión?

Porque pg_reload_conf() envía una señal SIGHUP al proceso maestro (postmaster), el cual relee postgresql.auto.conf, aplica los cambios globales y notifica el evento antes de propagarlo a los procesos hijos (backends).

¿Qué pasaría si alguien ejecutara ALTER SYSTEM SET log_statement = 'none'? ¿Quedaría rastro?

Sí quedaría rastro. Como log_statement valía 'ddl' antes de ejecutar la orden, la propia sentencia ALTER SYSTEM queda registrada, y además el proceso principal escribe el evento de cambio de parámetro (parameter "log_statement" changed to "none") al recargar la configuración.

¿Por qué no se recomienda editar postgresql.auto.conf a mano?

Porque ese archivo es administrado exclusivamente por PostgreSQL mediante ALTER SYSTEM; editarlo manualmente puede introducir errores de sintaxis que impidan recargar o iniciar el servidor, o bien ser sobrescrito en la siguiente ejecución de ALTER SYSTEM.