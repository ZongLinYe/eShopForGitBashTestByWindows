# eShop

基於 ASP.NET MVC 5 + .NET Framework 4.6.2 的電子商務網站。

---

## 資料庫初始化

資料庫腳本放置於 [`DatabaseScripts/`](DatabaseScripts/) 資料夾，使用版號命名（`V{版號}_{說明}.sql`）。

| 版本 | 腳本 | 說明 |
|------|------|------|
| V001 | [V001_CreateEShopDB.sql](DatabaseScripts/V001_CreateEShopDB.sql) | 建立 eShopDB 資料庫、7 張資料表及種子資料 |

**執行方式**：請參閱 [specs/001-db-init-script/quickstart.md](specs/001-db-init-script/quickstart.md)

---

## 建置

```bash
# 進入專案根目錄後執行
bash build.sh
```