-- ============================================================
-- DDL: 金融商品喜好紀錄系統
-- ============================================================

-- 清除舊資料
DROP TABLE IF EXISTS like_list CASCADE;
DROP TABLE IF EXISTS products  CASCADE;
DROP TABLE IF EXISTS users     CASCADE;
DROP TABLE IF EXISTS members   CASCADE;

-- ============================================================
-- Table: users (使用者)
-- ============================================================
CREATE TABLE users (
    user_id   VARCHAR(20)  NOT NULL,
    user_name VARCHAR(100) NOT NULL,
    email     VARCHAR(100) NOT NULL,
    account   VARCHAR(20)  NOT NULL,
    CONSTRAINT pk_users PRIMARY KEY (user_id)
);

-- ============================================================
-- Table: products (金融商品)
-- ============================================================
CREATE TABLE products (
    no           SERIAL        NOT NULL,
    product_name VARCHAR(200)  NOT NULL,
    price        NUMERIC(18,2) NOT NULL CHECK (price > 0),
    fee_rate     NUMERIC(6,4)  NOT NULL CHECK (fee_rate >= 0),
    CONSTRAINT pk_products PRIMARY KEY (no)
);

-- ============================================================
-- Table: like_list (喜好清單)
--   * 每筆喜好對應一筆 products 記錄（1:1）
--   * 需同時異動 products + like_list，請使用 Transaction
-- ============================================================
CREATE TABLE like_list (
    sn                SERIAL        NOT NULL,
    user_id           VARCHAR(20)   NOT NULL,
    product_no        INTEGER       NOT NULL,
    purchase_quantity INTEGER       NOT NULL CHECK (purchase_quantity > 0),
    account           VARCHAR(20)   NOT NULL,
    total_fee         NUMERIC(18,2) NOT NULL,
    total_amount      NUMERIC(18,2) NOT NULL,
    created_at        TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_like_list   PRIMARY KEY (sn),
    CONSTRAINT fk_ll_user     FOREIGN KEY (user_id)    REFERENCES users(user_id),
    CONSTRAINT fk_ll_product  FOREIGN KEY (product_no) REFERENCES products(no)
);

-- 授予 esun_user 權限
GRANT ALL PRIVILEGES ON ALL TABLES    IN SCHEMA public TO esun_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO esun_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES    TO esun_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO esun_user;
