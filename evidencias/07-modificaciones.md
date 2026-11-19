# Evidencia 07: Modificaciones de Datos (ddl frente a mod)

**Estudiante:** Irwin Gabriel Martinez Prado  
**Actividad:** Actividad 7 — Modificaciones de datos: ddl frente a mod  

---

## 1. Comandos Ejecutados
```sql
ALTER SYSTEM SET log_statement = 'mod';
SELECT pg_reload_conf();

psql -c "UPDATE clientes SET telefono = '6679990000' WHERE id = 3" -c "SELECT nombre, rfc FROM clientes WHERE id = 3" "postgresql://app_ventas:<REDACTED>@127.0.0.1/comercial?application_name=app-ventas-web"

2. Resultado Obtenido
Con log_statement = 'ddl' no se registraron sentencias UPDATE. Al cambiar a log_statement = 'mod', la bitácora registró la sentencia UPDATE completa junto con el usuario, IP y aplicación, pero omitió la sentencia SELECT.
3. Respuestas
¿Qué nivel habría registrado la lectura del RFC? ¿Qué costo tendría en un servidor con miles de consultas por minuto?El nivel log_statement = 'all'. En un servidor de alto tráfico generaría un crecimiento acelerado del tamaño de los archivos de bitácora, saturación de operaciones de escritura en disco (I/O) y degradación del rendimiento general del motor.   
¿Qué le falta a esta bitácora para revertir el cambio con certeza?Le falta registrar el valor anterior (OLD) que tenía la columna antes de ejecutarse el UPDATE, ya que la bitácora de sentencias únicamente almacena el texto SQL ejecutado.   