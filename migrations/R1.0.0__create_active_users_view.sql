-- ============================================================
-- R1.0.0: アクティブユーザービューの作成
-- ============================================================
-- このスクリプトは変更があれば毎回実行されます（Repeatable）

CREATE OR REPLACE VIEW APP.ACTIVE_USERS AS
SELECT
    u.USER_ID,
    u.USERNAME,
    u.EMAIL,
    COUNT(o.ORDER_ID) AS ORDER_COUNT,
    SUM(o.TOTAL_AMOUNT) AS TOTAL_SPENT
FROM APP.USERS u
LEFT JOIN APP.ORDERS o ON u.USER_ID = o.USER_ID
GROUP BY u.USER_ID, u.USERNAME, u.EMAIL
HAVING COUNT(o.ORDER_ID) > 0;

-- 完了メッセージ
SELECT 'View APP.ACTIVE_USERS created successfully' AS status;

