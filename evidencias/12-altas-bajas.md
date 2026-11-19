# Evidencia 12: Auditoría de Altas y Bajas (INSERT y DELETE)

**Estudiante:** Irwin Gabriel Martinez Prado  
**Actividad:** Actividad 13 — Altas y bajas  

---

## 1. Resultado Obtenido
Al insertar y posteriormente eliminar al cliente `Pedro Ruiz` (`id = 6`), la tabla `auditoria.cambios_clientes` conservó tanto el evento `INSERT` (con todos los datos en `valores_despues`) como el evento `DELETE` (con el respaldo completo en `valores_antes`).

## 2. Respuestas a las Preguntas
1. **El cliente Pedro Ruiz ya no existe en `clientes`. ¿Dónde queda evidencia de que existió y de sus datos?**  
   En los registros de `auditoria.cambios_clientes` correspondientes a las operaciones `INSERT` (`valores_despues`) y `DELETE` (`valores_antes`).
2. **¿Por qué `ip_cliente` está vacía en los eventos 2 y 3?**  
   Porque las operaciones fueron ejecutadas desde la sesión local de administrador (`psql` conectado mediante socket/loopback local sin dirección IP remota asignada), por lo que `inet_client_addr()` devuelve `NULL`.
3. **La política de retención de la Unidad II pedía eliminar datos cuando ya no fueran necesarios. ¿Qué conflicto aparece? ¿Quién debe resolverlo?**  
   Aparece un conflicto entre el **derecho de supresión / minimización de datos personales** (eliminar datos de clientes inactivos) y la **integridad / inmutabilidad de las pistas de auditoría** (conservar evidencia histórica). Debe resolverlo el área de **Gobierno de Datos / Cumplimiento Legal y Seguridad** definiendo plazos legales de retención o técnicas de anonimización/seudonimización tras cumplir el periodo obligatorio de auditoría.