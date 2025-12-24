-- ============================================================
-- V1.1.0__create_games_raw_table.sql
-- RAW テーブルを作成（生データ格納用）
-- ============================================================

CREATE TABLE IF NOT EXISTS RAW_ZELDA.GAMES_RAW (
  RAW_DATA VARIANT,
  LOADED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- テーブルコメント
COMMENT ON TABLE RAW_ZELDA.GAMES_RAW IS 'Zelda ゲーム生データ格納テーブル';
