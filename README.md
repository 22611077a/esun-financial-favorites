# 金融商品喜好紀錄系統

使用者可以新增、查詢、修改、刪除自己喜好的金融商品，系統會自動計算手續費與預計扣款總金額。

## 技術棧

- **後端**：Java 21、Spring Boot 4.0、Spring JDBC、Maven
- **資料庫**：PostgreSQL 17
- **前端**：Vue 3、Vite、Axios

## 專案結構

```
├── DB/
│   ├── 01-ddl.sql                # 建表
│   ├── 02-stored-procedures.sql  # Stored Procedures
│   └── 03-dml.sql                # 測試資料
├── backend/                      # Spring Boot（Controller / Service / Repository / common）
├── frontend/                     # Vue 3
└── 啟動系統.bat                  # 一鍵啟動
```

## 啟動方式

**一鍵啟動**：雙擊根目錄的 `啟動系統.bat`，等約 20 秒後瀏覽器會自動開啟。

**手動啟動**：

```bash
# 後端
cd backend && mvn spring-boot:run

# 前端（另開終端機）
cd frontend && npm install && npm run dev
```

## 資料庫初始化

第一次使用前執行：

```bash
psql -U postgres -d esun_db -f DB/01-ddl.sql
psql -U postgres -d esun_db -f DB/02-stored-procedures.sql
psql -U postgres -d esun_db -f DB/03-dml.sql
```

## API

| Method | 路徑 | 說明 |
|--------|------|------|
| GET | `/api/users` | 查詢所有使用者 |
| GET | `/api/favorites?userId={id}` | 查詢喜好清單 |
| POST | `/api/favorites` | 新增喜好商品 |
| PUT | `/api/favorites/{sn}` | 修改喜好商品 |
| DELETE | `/api/favorites/{sn}` | 刪除喜好商品 |
