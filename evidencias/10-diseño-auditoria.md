# Evidencia 10: Diseño y Creación del Registro de Auditoría

**Estudiante:** Irwin Gabriel Martinez Prado  
**Actividad:** Actividad 10 — Diseñar y crear el registro de auditoría  

---

## 1. Matriz de Diseño de Campos

| Campo propuesto | Tipo | ¿Qué pregunta responde? | ¿Puede ser nulo? ¿Por qué? |
| :--- | :--- | :--- | :--- |
| **`id_evento`** | `BIGSERIAL` | Identificador único y orden secuencial del evento | **No** (`PRIMARY KEY`), garantiza unicidad e integridad referencial. |
| **`momento`** | `TIMESTAMPTZ` | ¿Cuándo ocurrió el cambio? | **No**, toda evidencia forense requiere marca temporal exacta con zona horaria. |
| **`usuario_sesion`** | `TEXT` | ¿Quién hizo el cambio (rol autenticado)? | **No**, identifica al actor real (`session_user`). |
| **`usuario_efectivo`** | `TEXT` | ¿Bajo qué privilegios ejecutó el disparador? | **No**, distingue la ejecución `SECURITY DEFINER` (`current_user`). |
| **`aplicacion`** | `TEXT` | ¿Desde qué aplicación se conectó? | **Sí**, el cliente puede omitir el parámetro `application_name`. |
| **`ip_cliente`** | `INET` | ¿Desde qué equipo/dirección IP se conectó? | **Sí**, conexiones por socket local (`local`) no tienen dirección IP asignada. |
| **`operacion`** | `TEXT` | ¿Qué acción se realizó (`INSERT`/`UPDATE`/`DELETE`)? | **No**, define la naturaleza de la modificación. |
| **`id_cliente`** | `BIGINT` | ¿Sobre qué registro específico ocurrió? | **Sí** (en diseño general), aunque en esta tabla siempre identifica la llave del cliente afectado. |
| **`valores_antes`** | `JSONB` | ¿Qué valores tenía el registro antes del cambio? | **Sí**, en operaciones `INSERT` no existe estado previo (`OLD`). |
| **`valores_despues`** | `JSONB` | ¿Qué valores quedaron después del cambio? | **Sí**, en operaciones `DELETE` no existe estado posterior (`NEW`). |

---

## 2. Respuestas a las Preguntas
1. **¿Por qué `momento` usa `TIMESTAMPTZ` y no `TIMESTAMP`?**  
   Porque `TIMESTAMPTZ` almacena el instante exacto normalizado en UTC y lo convierte automáticamente según la zona horaria de consulta, evitando ambigüedades por cambios de horario de verano o servidores en distintas ubicaciones.
2. **¿Por qué se guarda el registro completo en `JSONB` y no solo la columna que cambió?**  
   Porque conserva una fotografía completa e inmutable de toda la fila sin depender del esquema fijo; si en el futuro se agregan o eliminan columnas en `clientes`, la estructura de `auditoria.cambios_clientes` sigue funcionando sin alterarse.
3. **La tabla de auditoría también contendrá RFC. ¿Qué implica eso para su clasificación y su control de acceso?**  
   Implica que la tabla de auditoría hereda el mismo nivel de clasificación confidencial/datos personales que la tabla `clientes`. Por ello debe residir en un esquema separado (`auditoria`) con permisos revocados a `PUBLIC` y acceso restringido exclusivamente al personal de auditoría/DBA.