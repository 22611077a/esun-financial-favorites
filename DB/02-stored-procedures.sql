-- ============================================================
-- Stored Procedures: 金融商品喜好紀錄系統
-- ============================================================

-- ------------------------------------------------------------
-- SP: 查詢所有使用者
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION sp_get_all_users()
RETURNS TABLE(user_id VARCHAR, user_name VARCHAR, email VARCHAR, account VARCHAR)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
        SELECT u.user_id, u.user_name, u.email, u.account
        FROM users u
        ORDER BY u.user_id;
END;
$$;

-- ------------------------------------------------------------
-- SP: 新增喜好金融商品
--   * 同時 INSERT products + like_list（Transaction 由 Spring @Transactional 管控）
--   * 回傳新增的 sn
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION sp_add_favorite(
    p_user_id           VARCHAR,
    p_product_name      VARCHAR,
    p_price             NUMERIC,
    p_fee_rate          NUMERIC,
    p_account           VARCHAR,
    p_purchase_quantity INTEGER
) RETURNS INTEGER
LANGUAGE plpgsql AS $$
DECLARE
    v_product_no   INTEGER;
    v_sn           INTEGER;
    v_total_fee    NUMERIC(18,2);
    v_total_amount NUMERIC(18,2);
BEGIN
    -- 驗證使用者存在
    IF NOT EXISTS (SELECT 1 FROM users WHERE user_id = p_user_id) THEN
        RAISE EXCEPTION 'USER_NOT_FOUND: %', p_user_id;
    END IF;

    -- 計算費用
    v_total_fee    := ROUND(p_price * p_purchase_quantity * p_fee_rate, 2);
    v_total_amount := ROUND(p_price * p_purchase_quantity + v_total_fee, 2);

    -- 新增金融商品
    INSERT INTO products (product_name, price, fee_rate)
    VALUES (p_product_name, p_price, p_fee_rate)
    RETURNING no INTO v_product_no;

    -- 新增喜好清單
    INSERT INTO like_list (user_id, product_no, purchase_quantity, account, total_fee, total_amount)
    VALUES (p_user_id, v_product_no, p_purchase_quantity, p_account, v_total_fee, v_total_amount)
    RETURNING sn INTO v_sn;

    RETURN v_sn;
END;
$$;

-- ------------------------------------------------------------
-- SP: 查詢喜好金融商品清單（JOIN users + products）
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION sp_get_favorites(p_user_id VARCHAR)
RETURNS TABLE(
    sn                INTEGER,
    product_name      VARCHAR,
    price             NUMERIC,
    fee_rate          NUMERIC,
    purchase_quantity INTEGER,
    account           VARCHAR,
    total_fee         NUMERIC,
    total_amount      NUMERIC,
    email             VARCHAR,
    user_name         VARCHAR
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
        SELECT l.sn,
               p.product_name,
               p.price,
               p.fee_rate,
               l.purchase_quantity,
               l.account,
               l.total_fee,
               l.total_amount,
               u.email,
               u.user_name
        FROM like_list l
        JOIN products p ON l.product_no = p.no
        JOIN users    u ON l.user_id    = u.user_id
        WHERE l.user_id = p_user_id
        ORDER BY l.sn;
END;
$$;

-- ------------------------------------------------------------
-- SP: 更改喜好金融商品資訊
--   * 同時 UPDATE products + like_list（Transaction 由 Spring @Transactional 管控）
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION sp_update_favorite(
    p_sn                INTEGER,
    p_product_name      VARCHAR,
    p_price             NUMERIC,
    p_fee_rate          NUMERIC,
    p_account           VARCHAR,
    p_purchase_quantity INTEGER
) RETURNS BOOLEAN
LANGUAGE plpgsql AS $$
DECLARE
    v_product_no   INTEGER;
    v_total_fee    NUMERIC(18,2);
    v_total_amount NUMERIC(18,2);
BEGIN
    -- 取得對應的 product_no
    SELECT product_no INTO v_product_no
    FROM like_list
    WHERE sn = p_sn;

    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;

    -- 重新計算費用
    v_total_fee    := ROUND(p_price * p_purchase_quantity * p_fee_rate, 2);
    v_total_amount := ROUND(p_price * p_purchase_quantity + v_total_fee, 2);

    -- 更新金融商品
    UPDATE products
    SET product_name = p_product_name,
        price        = p_price,
        fee_rate     = p_fee_rate
    WHERE no = v_product_no;

    -- 更新喜好清單
    UPDATE like_list
    SET purchase_quantity = p_purchase_quantity,
        account           = p_account,
        total_fee         = v_total_fee,
        total_amount      = v_total_amount,
        updated_at        = CURRENT_TIMESTAMP
    WHERE sn = p_sn;

    RETURN TRUE;
END;
$$;

-- ------------------------------------------------------------
-- SP: 刪除喜好金融商品資訊
--   * 同時 DELETE like_list + products（Transaction 由 Spring @Transactional 管控）
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION sp_delete_favorite(p_sn INTEGER)
RETURNS BOOLEAN
LANGUAGE plpgsql AS $$
DECLARE
    v_product_no INTEGER;
BEGIN
    -- 取得對應的 product_no
    SELECT product_no INTO v_product_no
    FROM like_list
    WHERE sn = p_sn;

    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;

    -- 刪除喜好清單（先刪子表）
    DELETE FROM like_list WHERE sn = p_sn;

    -- 刪除金融商品（再刪主表）
    DELETE FROM products WHERE no = v_product_no;

    RETURN TRUE;
END;
$$;

-- 授予 function 執行權限
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO esun_user;
