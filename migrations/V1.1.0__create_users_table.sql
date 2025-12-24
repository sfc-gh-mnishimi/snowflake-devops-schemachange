-- ============================================================
-- V1.1.0: ユーザーテーブルの作成
-- ============================================================
-- このスクリプトは一度だけ実行されます（Versioned）

CREATE TABLE IF NOT EXISTS APP.USERS (
    USER_ID INT AUTOINCREMENT PRIMARY KEY,
    USERNAME VARCHAR(100) NOT NULL,
    EMAIL VARCHAR(200) NOT NULL,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- 完了メッセージ
SELECT 'Table APP.USERS created successfully' AS status;

