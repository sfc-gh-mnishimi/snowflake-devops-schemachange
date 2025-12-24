-- ============================================================
-- V1.2.0: 注文テーブルの作成
-- ============================================================
-- このスクリプトは一度だけ実行されます（Versioned）

CREATE TABLE IF NOT EXISTS APP.ORDERS (
    ORDER_ID INT AUTOINCREMENT PRIMARY KEY,
    USER_ID INT NOT NULL,
    ORDER_DATE DATE NOT NULL,
    TOTAL_AMOUNT DECIMAL(10, 2),
    STATUS VARCHAR(50) DEFAULT 'PENDING',
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    FOREIGN KEY (USER_ID) REFERENCES APP.USERS(USER_ID)
);

-- 完了メッセージ
SELECT 'Table APP.ORDERS created successfully' AS status;

