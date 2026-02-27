# Quickstart: 執行資料庫建立腳本

**Phase 1 Output** | **Branch**: `001-db-init-script` | **Date**: 2026-02-27

---

## 前置需求

| 需求項目 | 版本要求 | 說明 |
|---------|---------|------|
| SQL Server | 2016+（任意版本） | 本機或區域網路，支援 Windows 驗證（Integrated Security） |
| SSMS 或 sqlcmd | 任意 | 擇一即可 |
| 執行帳號權限 | sysadmin 或 dbcreator | 需要建立資料庫的權限 |

---

## 方法 1：使用 SSMS（SQL Server Management Studio）

1. 開啟 **SSMS**，連線至目標 SQL Server（本機請選 `Windows 驗證`）。
2. 點選工具列 **File → Open → File...**，選取腳本：
   ```
   D:\VSCodeProject\GitBashWithMsbuildTest\eShop\DatabaseScripts\V001_CreateEShopDB.sql
   ```
3. 確認連線伺服器正確後，點選 **Execute**（或按 `F5`）。
4. 查看 Messages 面板，確認無錯誤訊息，最後顯示類似：
   ```
   Command(s) completed successfully.
   ```

---

## 方法 2：使用 sqlcmd（命令列）

```bash
# 以 Windows 驗證連線本機 SQL Server 並執行腳本
sqlcmd -S localhost -E -i "D:\VSCodeProject\GitBashWithMsbuildTest\eShop\DatabaseScripts\V001_CreateEShopDB.sql"
```

若 SQL Server 為具名執行個體（例如 `.\SQLEXPRESS`）：

```bash
sqlcmd -S ".\SQLEXPRESS" -E -i "D:\VSCodeProject\GitBashWithMsbuildTest\eShop\DatabaseScripts\V001_CreateEShopDB.sql"
```

---

## 執行後驗證

執行以下查詢確認資料庫建立成功：

```sql
USE eShopDB;
GO

-- 驗證 1：確認所有 7 張資料表存在
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
-- 預期結果：Banners, Categories, OrderItems, Orders, Products, TwoFactorTokens, Users

-- 驗證 2：確認種子資料筆數
SELECT 'Categories' AS TableName, COUNT(*) AS RowCount FROM Categories
UNION ALL
SELECT 'Products', COUNT(*) FROM Products
UNION ALL
SELECT 'Banners', COUNT(*) FROM Banners
UNION ALL
SELECT 'Users', COUNT(*) FROM Users;
-- 預期結果：Categories=4, Products=8, Banners=2, Users=1

-- 驗證 3：確認管理員帳號
SELECT Username, Email, Role, IsEmailVerified
FROM Users
WHERE Username = 'admin';
-- 預期結果：admin / admin@eshop.local / Admin / 1
```

---

## 重複執行安全確認

腳本採冪等性設計，**可重複執行**而不破壞現有資料：

- 若 `eShopDB` 已存在 → 跳過 `CREATE DATABASE`，直接切換至 `eShopDB`。
- 若資料表已存在 → 跳過 `CREATE TABLE`，保留現有資料。
- 若種子資料已存在 → 跳過 `INSERT`，不產生重複資料。

---

## 測試帳號登入資訊

| 項目 | 值 |
|------|-----|
| 帳號（Username） | `admin` |
| 密碼（明文，僅供開發測試） | `Admin@123456` |
| 角色 | `Admin` |
| Email | `admin@eshop.local` |

> ⚠️ **重要**：此為開發測試專用帳號，**禁止**在正式環境使用相同密碼。

---

## 常見問題

**Q：執行時出現「Login failed」錯誤？**
確認連線帳號具有 `dbcreator` 或 `sysadmin` 伺服器角色。

**Q：出現「Cannot open database eShopDB」錯誤？**
腳本執行未完成。請重新執行完整腳本（腳本有冪等保護，可安全重執行）。

**Q：種子管理員帳號密碼無法登入應用程式？**
確認 `eShopWeb/Web.config` 的 `<connectionStrings>` 指向正確的 SQL Server 執行個體。
