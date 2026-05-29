# 玉山銀行 — 金融商品喜好紀錄系統

玉山銀行後端工程師實作題。使用者可以新增、查詢、修改、刪除自己喜好的金融商品，系統會自動計算手續費與預計扣款總金額。

---

## 技術棧

| 分類 | 使用技術 |
|------|----------|
| 後端 | Java 21、Spring Boot 4.0、Spring JDBC |
| 資料庫 | PostgreSQL 17 |
| 前端 | Vue 3、Vite、Axios |
| 建構工具 | Maven 3.9 |

---

## 功能

- 新增喜好金融商品（同時寫入 `products` + `like_list`，Transaction 保護）
- 查詢某使用者的喜好清單（JOIN 三張表，含手續費計算結果）
- 修改商品資訊（同時更新 `products` + `like_list`）
- 刪除商品（同時刪除 `like_list` + `products`）
- SQL Injection 防護：所有 DB 操作透過 Stored Procedure + 參數化查詢
- XSS 防護：Servlet Filter 對所有輸入做 HTML 字元跳脫，並加上安全 Response Header

---

## 專案結構

```
esun/
├── DB/
│   ├── 01-ddl.sql                  # 建立 users / products / like_list 表
│   ├── 02-stored-procedures.sql    # 5 個 Stored Procedure
│   └── 03-dml.sql                  # 測試用的 3 筆使用者資料
├── backend/
│   └── src/main/java/com/esun/
│       ├── controller/             # API 路由層（接收請求、回傳結果）
│       ├── service/                # 商業邏輯層（@Transactional 在這層）
│       ├── repository/             # 資料存取層（呼叫 Stored Procedure）
│       ├── model/                  # 資料模型
│       ├── dto/                    # 輸入驗證（@Valid）
│       ├── common/                 # 統一 API 回應格式
│       └── config/                 # XSS Filter、全域例外處理
├── frontend/
│   └── src/
│       ├── views/FavoriteView.vue  # 主畫面（完整 CRUD + 即時金額預覽）
│       ├── services/api.js         # 集中管理所有 API 呼叫
│       └── router/                 # 前端路由
├── 啟動系統.bat                    # 一鍵啟動入口（雙擊執行）
└── launcher.ps1                    # 啟動腳本（由 bat 呼叫）
```

---

## 環境需求

- Java 21（Temurin）
- Maven 3.9+
- Node.js 18+
- PostgreSQL 17

---

## 資料庫初始化

第一次使用前，用 `psql` 依序執行：

```bash
psql -U postgres -d esun_db -f DB/01-ddl.sql
psql -U postgres -d esun_db -f DB/02-stored-procedures.sql
psql -U postgres -d esun_db -f DB/03-dml.sql
```

預設連線資訊（可透過環境變數覆寫）：

| 項目 | 預設值 |
|------|--------|
| Host | localhost:5432 |
| Database | esun_db |
| Username | `DB_USERNAME`（預設 esun_user） |
| Password | `DB_PASSWORD`（預設 esun_pass） |

---

## 啟動方式

### 一鍵啟動（建議）

雙擊根目錄的 **`啟動系統.bat`**

腳本會自動：
1. 清除佔用 8080 port 的舊程序
2. 背景啟動後端（Spring Boot）
3. 背景啟動前端（Vite）
4. 等後端就緒後自動開瀏覽器到 `http://localhost:5173`

### 手動分開啟動

```bash
# 後端
cd backend
mvn spring-boot:run

# 前端（另開終端機）
cd frontend
npm install   # 第一次需要
npm run dev
```

---

## API 端點

Base URL：`http://localhost:8080/api`

| Method | 路徑 | 說明 |
|--------|------|------|
| GET | `/users` | 取得所有使用者 |
| GET | `/favorites?userId={id}` | 查詢某使用者的喜好清單 |
| POST | `/favorites` | 新增喜好商品 |
| PUT | `/favorites/{sn}?userId={id}` | 修改喜好商品 |
| DELETE | `/favorites/{sn}` | 刪除喜好商品 |

所有回應統一格式：

```json
{
  "success": true,
  "message": "success",
  "data": { ... }
}
```

---

## 資料庫設計

```
users          (user_id PK, user_name, email, account)
products       (no PK SERIAL, product_name, price, fee_rate)
like_list      (sn PK SERIAL, user_id FK, product_no FK,
                purchase_quantity, account, total_fee, total_amount)
```

`like_list` 與 `products` 是 1:1 關係，每筆喜好對應一筆獨立的商品紀錄，這樣修改或刪除時不會影響其他使用者的資料。

---

## 後端架構

```
Controller  →  接收 HTTP 請求，呼叫 Service
Service     →  商業邏輯，@Transactional 保護多表操作
Repository  →  呼叫 Stored Procedure（SimpleJdbcCall / JdbcTemplate）
```

新增、修改、刪除都同時異動 `products` 和 `like_list` 兩張表，全部包在同一個 Transaction 裡，任一步驟失敗會整筆 rollback。
