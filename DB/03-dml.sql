-- ============================================================
-- DML: 範例資料
-- ============================================================

INSERT INTO users (user_id, user_name, email, account) VALUES
    ('A1236456789', '王o明', 'test@email.com',    '1111999666'),
    ('B9876543210', '李o芬', 'lee@email.com',     '2222888777'),
    ('C5551234567', '張o華', 'chang@email.com',   '3333777888')
ON CONFLICT (user_id) DO NOTHING;
