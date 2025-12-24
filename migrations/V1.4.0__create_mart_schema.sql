-- ============================================================
-- V1.4.0__create_mart_schema.sql
-- MART レイヤのスキーマを作成（分析用）
-- ============================================================

CREATE SCHEMA IF NOT EXISTS MART_ZELDA;

-- スキーマコメント
COMMENT ON SCHEMA MART_ZELDA IS '分析・レポート用データマート';
