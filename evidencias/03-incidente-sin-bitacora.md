# Evidencia 03: Simulación del Incidente sin Bitácora

**Estudiante:** Irwin Gabriel Martinez Prado  
**Actividad:** Actividad 3 — El incidente sin bitácora  

---

## 1. Comandos Ejecutados
```cmd
psql -c "UPDATE clientes SET rfc = 'GAMA780912XXX' WHERE id = 3" "postgresql://app_ventas:<REDACTED>@127.0.0.1/comercial?application_name=app-ventas-web"

```sql
SELECT linea FROM dba.bitacora WHERE linea ILIKE '%update%' OR linea LIKE '%app_ventas%';

```markdown
2. Resultado Obtenido
La actualización se ejecutó (UPDATE 1), modificando el RFC de María García. Sin embargo, al consultar dba.bitacora, no apareció ningún registro del UPDATE ni de la conexión exitosa de app_ventas.

3. Respuestas
¿Puedes demostrar quién modificó el RFC?

No. Al estar desactivados log_statement y log_connections, no existe rastro en la bitácora del servidor que vincule el cambio con un usuario o sesión.

¿Puedes demostrar que el cambio no lo hizo soporte_ana?

Indirectamente por permisos (soporte_ana solo tiene SELECT), pero sin bitácora no existe prueba forense directa de qué sesión ejecutó la sentencia ni descartar una escalada de privilegios o abuso de credenciales.

Los privilegios de la Unidad II, ¿impidieron el cambio? ¿Debían impedirlo?

No lo impidieron ni debían hacerlo, porque app_ventas requiere el privilegio UPDATE sobre clientes para operar legítimamente. El control de acceso regula lo permitido, pero no detecta el mal uso de privilegios válidos.

¿Qué tendría que haber estado configurado antes del incidente?

Deberían haber estado activos logging_collector = on, log_connections = on, log_line_prefix con %u, %d, %a, %h, log_statement = 'mod' (o un disparador de auditoría en la tabla clientes).