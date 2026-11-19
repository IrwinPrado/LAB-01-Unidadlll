# Evidencia 11: El Incidente Auditado

**Estudiante:** Irwin Gabriel Martinez Prado  
**Actividad:** Actividad 12 — El incidente auditado  

---

## 1. Resultado Obtenido
Al ejecutar el `UPDATE` sobre el RFC de María García (`id = 3`) desde `app_ventas`, el disparador registró el evento con `usuario_sesion = app_ventas`, `usuario_efectivo = postgres`, `aplicacion = app-ventas-web` e `ip_cliente = 127.0.0.1`. Cuando `app_ventas` intentó consultar la tabla de auditoría, recibió `ERROR: permission denied for schema auditoria`.

## 2. Respuestas a las Preguntas
1. **Compara tu hipótesis de la Actividad 11 con este resultado.**  
   Se confirma que sin `SECURITY DEFINER`, el disparador habría fallado con error de permisos al intentar insertar en `auditoria.cambios_clientes` desde la sesión de `app_ventas` (ya que `app_ventas` no tiene acceso al esquema `auditoria`). Además, `REVOKE ALL ON FUNCTION ... FROM PUBLIC` impide que `app_ventas` invoque la función directamente fuera del contexto del disparador.
2. **Escribe la sentencia `UPDATE` que restauraría el valor anterior.**  
   ```sql
   UPDATE clientes SET rfc = 'GAMA780912XYZ' WHERE id = 3;