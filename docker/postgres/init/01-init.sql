-- ============================================================
-- Table: members (會員資料)
-- ============================================================
CREATE TABLE IF NOT EXISTS members (
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(100)        NOT NULL,
    email      VARCHAR(100) UNIQUE NOT NULL,
    phone      VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- Stored Procedures (PostgreSQL functions)
-- ============================================================

-- SP: 查詢所有會員
CREATE OR REPLACE FUNCTION sp_get_all_members()
RETURNS TABLE(
    id         INT,
    name       VARCHAR,
    email      VARCHAR,
    phone      VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
        SELECT m.id, m.name, m.email, m.phone, m.created_at, m.updated_at
        FROM members m
        ORDER BY m.id;
END;
$$;

-- SP: 依 ID 查詢單筆會員
CREATE OR REPLACE FUNCTION sp_get_member_by_id(p_id INT)
RETURNS TABLE(
    id         INT,
    name       VARCHAR,
    email      VARCHAR,
    phone      VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
        SELECT m.id, m.name, m.email, m.phone, m.created_at, m.updated_at
        FROM members m
        WHERE m.id = p_id;
END;
$$;

-- SP: 新增會員，回傳新 ID
CREATE OR REPLACE FUNCTION sp_create_member(
    p_name  VARCHAR,
    p_email VARCHAR,
    p_phone VARCHAR
)
RETURNS INT
LANGUAGE plpgsql AS $$
DECLARE
    v_id INT;
BEGIN
    INSERT INTO members (name, email, phone)
    VALUES (p_name, p_email, p_phone)
    RETURNING id INTO v_id;
    RETURN v_id;
END;
$$;

-- SP: 更新會員資料，回傳是否成功
CREATE OR REPLACE FUNCTION sp_update_member(
    p_id    INT,
    p_name  VARCHAR,
    p_email VARCHAR,
    p_phone VARCHAR
)
RETURNS BOOLEAN
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE members
    SET name       = p_name,
        email      = p_email,
        phone      = p_phone,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_id;
    RETURN FOUND;
END;
$$;

-- SP: 刪除會員，回傳是否成功
CREATE OR REPLACE FUNCTION sp_delete_member(p_id INT)
RETURNS BOOLEAN
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM members WHERE id = p_id;
    RETURN FOUND;
END;
$$;

-- ============================================================
-- 測試資料
-- ============================================================
INSERT INTO members (name, email, phone) VALUES
    ('王小明', 'wang@example.com', '0912345678'),
    ('李大華', 'lee@example.com',  '0987654321')
ON CONFLICT (email) DO NOTHING;
