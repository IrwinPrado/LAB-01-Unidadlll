# Evidencia 13: Intento de Manipulación de la Auditoría

**Estudiante:** Irwin Gabriel Martinez Prado  
**Actividad:** Actividad 14 — Intentar manipular la auditoría  

---

## 1. Resultado Obtenido
* El usuario `app_ventas` fue bloqueado tanto al intentar borrar registros (`permission denied for schema auditoria`) como al intentar desactivar el disparador (`must be owner of table clientes`).
* El administrador (`postgres`) sí pudo ejecutar `DISABLE TRIGGER`, modificar el RFC sin generar fila en `auditoria.cambios_clientes` y reactivar el disparador (`ENABLE TRIGGER`). Sin embargo, todas esas sentencias DDL/DML quedaron registradas en `dba.bitacora`.

## 2. Respuestas a las Preguntas
1. **¿Qué evidencia permite detectar que hubo un cambio sin auditar?**  
   Las líneas registradas en la bitácora del servidor (`dba.bitacora`) que muestran la ejecución secuencial de `ALTER TABLE clientes DISABLE TRIGGER trg_auditoria_clientes`, el `UPDATE` intermedio y `ALTER TABLE clientes ENABLE TRIGGER trg_auditoria_clientes`.
2. **¿Qué control administrativo (no técnico) reduciría este riesgo?**  
   La revisión periódica e independiente de bitácoras por parte de un oficial de seguridad externo al equipo DBA, acompañada de políticas de control de cambios (autorización formal previa para cualquier `ALTER TABLE`) y envío centralizado de logs a un servidor SIEM/Syslog remoto donde el DBA no tenga permisos de escritura ni borrado.
3. **Relaciona esta actividad con el principio de separación de funciones de la Unidad II.**  
   Demuestra que quien administra y opera la base de datos no debe ser quien custodie ni tenga control exclusivo sobre las evidencias de auditoría; separar ambas funciones evita que un administrador con privilegios totales pueda encubrir modificaciones no autorizadas.