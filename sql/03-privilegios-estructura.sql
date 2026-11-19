-- ============================================================
-- LAB-01: Bitácoras y auditoría del dato en PostgreSQL
-- Script: 03-privilegios-estructura.sql
-- Estudiante: Irwin Gabriel Martinez Prado
-- Descripción: Ejecución de cambios de privilegios, estructura
--              y demostración de exposición de credenciales.
-- ============================================================

REVOKE UPDATE ON clientes FROM soporte_ana;
GRANT UPDATE ON clientes TO app_ventas;
ALTER TABLE clientes ADD COLUMN segmento VARCHAR(20);

-- Demostración de fuga de secreto en bitácora al usar PASSWORD en texto claro
CREATE ROLE rol_temporal LOGIN PASSWORD 'Temporal_Practica_2026';
DROP ROLE rol_temporal;