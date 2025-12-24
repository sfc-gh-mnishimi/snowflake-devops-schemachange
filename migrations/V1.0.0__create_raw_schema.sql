-- ============================================================
-- V1.0.0__create_raw_schema.sql
-- RAW レイヤのスキーマを作成
-- schemachange で自動デプロイされます
-- ============================================================

-- RAW スキーマ作成
CREATE SCHEMA IF NOT EXISTS RAW_ZELDA;

-- ファイルフォーマット作成
CREATE FILE FORMAT IF NOT EXISTS RAW_ZELDA.JSON_FORMAT
  TYPE = 'JSON'
  STRIP_OUTER_ARRAY = FALSE;

-- 内部ステージ作成
CREATE STAGE IF NOT EXISTS RAW_ZELDA.ZELDA_STAGE
  FILE_FORMAT = RAW_ZELDA.JSON_FORMAT;
