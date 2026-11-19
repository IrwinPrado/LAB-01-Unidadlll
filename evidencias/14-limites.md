# Evidencia 14: Límites de la Auditoría (Lecturas y Volumen)

**Estudiante:** Irwin Gabriel Martinez Prado  
**Actividad:** Actividad 15 — Límites: lecturas y volumen  

---

## 1. Resultado Obtenido
* La consulta `SELECT nombre, rfc, telefono` realizada por `soporte_ana` generó **0 registros** tanto en `dba.bitacora` (con `log_statement = 'mod'`) como en `auditoria.cambios_clientes`.
* El cambio masivo `UPDATE clientes SET segmento = 'regular';` generó **1 sola línea** en `dba.bitacora`, pero disparó **5 filas nuevas** en `auditoria.cambios_clientes` (una por cada cliente afectado, elevando el total de `UPDATE` a 6).

## 2. Respuestas a las Preguntas
1. **Si `clientes` tuviera un millón de registros, ¿qué ocurriría con la auditoría tras un `UPDATE` sin `WHERE`?**  
   El disparador `FOR EACH ROW` se ejecutaría un millón de veces dentro de la misma transacción, insertando un millón de documentos `JSONB` completos en `auditoria.cambios_clientes`. Esto multiplicaría el tiempo de ejecución de la consulta, bloquearía la tabla prolongadamente, saturaría el WAL (*Write-Ahead Logging*) y consumiría gigabytes de almacenamiento de forma abrupta.
2. **Propón quién podría autorizar la depuración de `auditoria.cambios_clientes`.**  
   Un comité o responsable formal de **Seguridad de la Información / Auditoría Interna / Oficial de Cumplimiento (DPO)** mediante una solicitud de cambio documentada y previa exportación/respaldo cifrado del histórico, nunca el DBA de forma unilateral.
3. **¿Por qué `log_statement = 'all'` puede convertir la bitácora en un nuevo depósito de datos sensibles?**  
   Porque registra el texto literal de todas las consultas `SELECT`, `INSERT` y `UPDATE` incluyendo filtros `WHERE`, parámetros con CURP, RFC, correos, tarjetas o tokens, replicando información confidencial en archivos de texto plano fuera de los controles de acceso de las tablas.