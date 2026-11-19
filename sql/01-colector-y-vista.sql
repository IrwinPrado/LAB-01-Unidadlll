-- ============================================================
-- LAB-01: Bitácoras y auditoría del dato en PostgreSQL
-- Script: 01-colector-y-vista.sql
-- Estudiante: Irwin Gabriel Martinez Prado
-- Descripción: Activación del colector de bitácoras y creación
--              de la vista restringida dba.bitacora.
-- ============================================================

-- 1. Activar el colector de bitácoras del motor (requiere reinicio)
ALTER SYSTEM SET logging_collector = on;

-- Verificar si requiere reinicio
SELECT name, setting, pending_restart 
FROM pg_settings 
WHERE name = 'logging_collector';

-- 2. Consultar ruta del archivo de bitácora vigente
SELECT pg_current_logfile();

-- 3. Crear esquema exclusivo del DBA y vista de lectura de bitácora
CREATE SCHEMA IF NOT EXISTS dba;
REVOKE ALL ON SCHEMA dba FROM PUBLIC;

CREATE OR REPLACE VIEW dba.bitacora AS
SELECT t.n AS num, rtrim(t.linea, E'\r') AS linea
FROM regexp_split_to_table(pg_read_file(pg_current_logfile()), E'\n')
WITH ORDINALITY AS t(linea, n)
WHERE rtrim(t.linea, E'\r') <> '';