# Evidencia 06: Cambios de Privilegios, Estructura y Exposición de Secretos

**Estudiante:** Irwin Gabriel Martinez Prado  
**Actividad:** Actividad 6 — Cambios de privilegios y de estructura  

---

## 1. Comandos Ejecutados
```sql
REVOKE UPDATE ON clientes FROM soporte_ana;
GRANT UPDATE ON clientes TO app_ventas;
ALTER TABLE clientes ADD COLUMN segmento VARCHAR(20);
CREATE ROLE rol_temporal LOGIN PASSWORD '<REDACTED>';
DROP ROLE rol_temporal;

```markdown

2. Resultado Obtenido
Con log_statement = 'ddl', PostgreSQL registró las cinco sentencias antes de su ejecución, incluyendo en texto claro la contraseña proporcionada directamente dentro de la sentencia CREATE ROLE.

3. Respuestas 
¿Qué tipo de evento es cada una de las tres primeras sentencias (privilegio o estructura)?

REVOKE UPDATE ON clientes FROM soporte_ana;: Evento de privilegio.

GRANT UPDATE ON clientes TO app_ventas;: Evento de privilegio.

ALTER TABLE clientes ADD COLUMN segmento VARCHAR(20);: Evento de estructura.

¿Por qué GRANT y REVOKE quedan registrados con log_statement = 'ddl'?

Porque en la clasificación interna de PostgreSQL las sentencias DCL (Data Control Language) de gestión de roles y permisos se agrupan dentro de la categoría ddl para garantizar la trazabilidad de cambios de seguridad sin tener que activar el registro masivo de modificaciones de datos (mod).

Si la bitácora contiene contraseñas, ¿quién debería poder leerla? Relaciónalo con la gestión de secretos de la Unidad II.

Únicamente personal administrador autorizado (DBA) bajo controles estrictos de acceso. Tal como se establece en la gestión de secretos de la Unidad II, las credenciales nunca deben enviarse en texto claro dentro de sentencias SQL (debe usarse \password para generar el hash SCRAM en el cliente) y cualquier archivo de bitácora exportado debe sanitizarse (<REDACTED>) antes de compartirse o almacenarse en repositorios.