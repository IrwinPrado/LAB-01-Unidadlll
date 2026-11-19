-- ============================================================
-- LAB-01: Bitácoras y auditoría del dato en PostgreSQL
-- Script: 02-configuracion-bitacora.sql
-- Estudiante: Irwin Gabriel Martinez Prado
-- Descripción: Configuración de parámetros de registro de
--              conexiones, prefijo de línea y sentencias DDL.
-- ============================================================

ALTER SYSTEM SET log_connections = on;
ALTER SYSTEM SET log_disconnections = on;
ALTER SYSTEM SET log_line_prefix = '%m [%p] user=%u db=%d app=%a client=%h ';
ALTER SYSTEM SET log_statement = 'ddl';

-- Aplicar cambios sin reiniciar el servicio
SELECT pg_reload_conf();

-- Verificar aplicación en archivo de configuración
SELECT name, setting, applied, sourcefile
FROM pg_file_settings
WHERE name IN ('log_connections', 'log_disconnections', 'log_line_prefix', 'log_statement');