# Evidencia 05: Registro de Accesos Exitosos y Fallidos

**Estudiante:** Irwin Gabriel Martinez Prado  
**Actividad:** Actividad 5 — Accesos exitosos y fallidos  

---

## 1. Comandos Ejecutados
```cmd
psql -c "SELECT 1" "postgresql://app_ventas:<REDACTED>@127.0.0.1/comercial"
psql -c "SELECT 1" "postgresql://usuario_inexistente:<REDACTED>@127.0.0.1/comercial"
psql -c "SELECT count(*) FROM clientes" "postgresql://app_ventas:<REDACTED>@127.0.0.1/comercial?application_name=app-ventas-web"

```sql

SELECT linea FROM dba.bitacora WHERE linea LIKE '%client=127.0.0.1%' ORDER BY num DESC LIMIT 12;

```markdown

2. Resultado Obtenido
La bitácora registró los dos intentos fallidos con severidad FATAL detallando la regla de pg_hba.conf evaluada y el motivo específico (password authentication failed y Role "usuario_inexistente" does not exist), así como la secuencia completa de conexión recibida, autenticada (scram-sha-256), autorizada y desconectada para app_ventas con application_name=app-ventas-web.

3. Respuestas
La bitácora registra el usuario app_ventas en el intento fallido. ¿Eso prueba que la aplicación de ventas intentó entrar? ¿Qué prueba realmente?

No prueba que haya sido la aplicación legítima. Prueba únicamente que alguien desde la dirección IP 127.0.0.1 intentó iniciar sesión declarando el nombre de rol app_ventas sin conocer su contraseña.

¿Qué información adicional registra PostgreSQL cuando el rol no existe? ¿Por qué aparece en la bitácora y no en el mensaje que recibe el cliente?

Registra la línea DETAIL: Role "usuario_inexistente" does not exist. No se envía al cliente para evitar la enumeración de usuarios válidos (el cliente recibe un error genérico de fallo de autenticación para no revelar qué cuentas existen en el sistema).

¿Por qué app=[unknown] en el intento fallido, pero app=app-ventas-web en la desconexión?

Porque el parámetro application_name se negocia después de completar la fase de autenticación; en un intento fallido la sesión se corta antes de recibir dicho parámetro, mientras que al desconectarse tras una sesión exitosa ya fue establecido.

¿Qué patrón de varias líneas te haría sospechar de un ataque de fuerza bruta? Escribe la consulta que contaría los intentos fallidos por usuario.

Múltiples líneas consecutivas con FATAL: password authentication failed provenientes de una misma IP en un intervalo corto de tiempo.