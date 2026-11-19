-- ============================================================
-- LAB-01: Bitácoras y auditoría del dato en PostgreSQL
-- Script: 04-esquema-auditoria.sql
-- Estudiante: Irwin Gabriel Martinez Prado
-- Descripción: Creación del esquema protegido de auditoría y
--              la tabla cambios_clientes con captura JSONB.
-- ============================================================

CREATE SCHEMA IF NOT EXISTS auditoria;
REVOKE ALL ON SCHEMA auditoria FROM PUBLIC;

CREATE TABLE IF NOT EXISTS auditoria.cambios_clientes (
    id_evento        BIGSERIAL PRIMARY KEY,
    momento          TIMESTAMPTZ NOT NULL DEFAULT now(),
    usuario_sesion   TEXT        NOT NULL DEFAULT session_user,
    usuario_efectivo TEXT        NOT NULL DEFAULT current_user,
    aplicacion       TEXT        DEFAULT current_setting('application_name'),
    ip_cliente       INET        DEFAULT inet_client_addr(),
    operacion        TEXT        NOT NULL,
    id_cliente       BIGINT,
    valores_antes    JSONB,
    valores_despues  JSONB
);