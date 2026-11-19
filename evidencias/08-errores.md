# Evidencia 08: Errores y Operaciones Rechazadas

**Estudiante:** Irwin Gabriel Martinez Prado  
**Actividad:** Actividad 8 — Errores y operaciones rechazadas  

---

## 1. Comandos Ejecutados
```cmd
psql -c "DELETE FROM clientes WHERE id = 5" "postgresql://soporte_ana:<REDACTED>@127.0.0.1/comercial"

DROP ROLE soporte_ana;

2. Resultado ObtenidoDurante la ejecución del reporte se observó la sesión activa de soporte_ana con application_name = reporte-mensual y su pid asignado. Al finalizar la consulta, la fila desapareció de pg_stat_activity, pero sus eventos permanecieron en dba.bitacora.

3. Respuestas
¿Qué columna permite relacionar una sesión con sus líneas de bitácora?La columna pid (identificador de proceso del sistema operativo), que aparece entre corchetes [%p] en el prefijo de cada línea de la bitácora.   
Después de que termina el reporte, ¿qué fuente conserva evidencia de que existió?La bitácora del servidor (dba.bitacora), ya que pg_stat_activity solo muestra el estado instantáneo de las conexiones activas en ese momento.   
¿Por qué client_addr aparece vacío en la sesión del administrador?Porque la sesión local del administrador se conectó sin especificar interfaz TCP/IP (localhost / socket local) o sin dirección remota asignada.