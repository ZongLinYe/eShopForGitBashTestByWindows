# Research: 新增資料庫建立腳本

**Phase 0 Output** | **Branch**: `001-db-init-script` | **Date**: 2026-02-27

---

## R-001：冪等性 T-SQL 腳本設計模式

### 決策
採用 `IF NOT EXISTS` 守衛模式建立資料庫與資料表，不使用 `DROP DATABASE / DROP TABLE` 破壞性指令。種子資料使用 `IF NOT EXISTS (SELECT 1 FROM ...)` 條件插入。

### 理由
- 腳本可在同一環境重複執行，不破壞現有資料（SC-004 要求）。
- 適用於開發環境重建與 QA 環境初始化（User Story 2）。
- SQL Server 標準做法，無需額外套件或工具。

### 替代方案評估
| 方案 | 評估結果 |
|------|---------|
| `DROP DATABASE IF EXISTS` + 重建 | 快速但會清除所有現有資料，不符合冪等安全性要求 |
| EF6 Migrations | 需要 C# 專案整合，超出本功能範圍（YAGNI） |
| SQL Server DACPAC | 需 Visual Studio SQL Server Data Tools，環境依賴過重 |

### 實作模式
```sql
-- 資料庫層級
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'eShopDB')
BEGIN
    CREATE DATABASE eShopDB;
END
GO

USE eShopDB;
GO

-- 資料表層級
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Users]') AND type = N'U')
BEGIN
    CREATE TABLE [dbo].[Users] ( ... );
END
GO

-- 種子資料層級
IF NOT EXISTS (SELECT 1 FROM [dbo].[Users] WHERE Username = 'admin')
BEGIN
    INSERT INTO [dbo].[Users] (...) VALUES (...);
END
```

---

## R-002：使用者密碼雜湊儲存格式（PBKDF2）

### 決策
種子管理員帳號採用 **PBKDF2-SHA256** 演算法預先計算雜湊後存入腳本。格式：`PasswordHash`（Base64 字串，256-bit 雜湊輸出）、`PasswordSalt`（Base64 字串，128-bit 隨機鹽）。

### 理由
- 與應用程式 `AuthService.Register()` 使用相同演算法（`Rfc2898DeriveBytes`，SHA256，310,000 次迭代），確保種子帳號可透過系統登入驗證（AC 3 of User Story 1）。
- .NET Framework 4.6.2 內建支援，不引入額外套件。
- 種子腳本中可直接以預計算的雜湊字串插入，不暴露明文密碼。

### 種子帳號規格
| 欄位 | 值 |
|------|-----|
| Username | `admin` |
| Email | `admin@eshop.local` |
| 明文密碼（僅文件記錄，不進腳本） | `Admin@123456` |
| 演算法 | PBKDF2-SHA256，310,000 次迭代，128-bit salt |
| Role | `Admin` |
| IsEmailVerified | `1`（預設已驗證） |
| TwoFactorMethod | `0`（無，預設以 Email OTP） |

> **注意**：實作時由系統單元測試或獨立工具程式預先產生 `PasswordHash` 與 `PasswordSalt` 的 Base64 值後填入腳本。

### 替代方案評估
| 方案 | 評估結果 |
|------|---------|
| 明文密碼欄位 | 安全性不可接受 |
| BCrypt | 需額外 NuGet 套件，與應用層使用的 PBKDF2 不一致 |
| 資料庫內建加密 | 應用層無對應解密邏輯 |

---

## R-003：使用者角色欄位型別（Role）

### 決策
`Users.Role` 欄位使用 `NVARCHAR(20) NOT NULL`，儲存角色名稱的字串值（`Member`、`VipMember`、`Admin`、`SuperAdmin`）。

### 理由
- 與 ASP.NET MVC `[Authorize(Roles = "Admin")]` 直接對應，無需額外映射。
- `Application_PostAuthenticateRequest` 從 Session / Claims 讀取 Role 時直接使用字串。
- AGENTS.md 規定角色名稱（字串）使用英文，與 `[Authorize]` 對應。

### 替代方案評估
| 方案 | 評估結果 |
|------|---------|
| INT（對應 C# enum 整數值） | 需要應用層手動轉換，增加維護成本 |
| 關聯資料表（Roles）| 正規化過度設計，角色集合固定不需動態管理（YAGNI） |

---

## R-004：雙因素驗證方式欄位型別（TwoFactorMethod）

### 決策
`Users.TwoFactorMethod` 欄位使用 `INT NOT NULL DEFAULT 0`，對應 C# `enum TwoFactorMethod { Email = 0, Totp = 1 }`。

### 理由
- 列舉值集合固定（Email OTP、TOTP 兩種），INT 儲存簡潔。
- `DEFAULT 0` 表示新帳號預設使用 Email OTP，符合安全性最低配置原則。
- EF6 Database First 反向工程後，`DbContext` 對應欄位可直接轉型為 C# enum。

---

## R-005：`TwoFactorTokens` 有效期限策略

### 決策
`TwoFactorTokens.ExpiresAt` 設計為 `DATETIME2 NOT NULL`，應用層於插入時計算 `GETUTCDATE() + 5 分鐘`，驗證時比對 `ExpiresAt > GETUTCDATE()` 且 `IsUsed = 0`。

### 理由
- 5 分鐘有效期符合業界 Email OTP 標準，兼顧安全性與使用者便利性。
- UTC 時間避免時區問題（本地開發至未來部署的一致性）。
- `IsUsed` 旗標防止同一 token 被重複使用（Replay Attack）。

---

## R-006：`OrderItems` 商品快照設計

### 決策
`OrderItems` 資料表增加 `ProductName NVARCHAR(200) NOT NULL` 與 `UnitPrice DECIMAL(18,2) NOT NULL` 欄位，下單時由應用層從 `Products` 複製當下值存入。

### 理由
- 商品未來可能改名或調價，歷史訂單明細必須呈現下單當下的資訊（FR-006）。
- 快照設計不需 JOIN Products 即可呈現完整訂單，查詢效能較好。
- 同時保留 `ProductId FK` 供統計分析使用（可接受 NULL 外鍵，商品刪除後仍保留快照）。

---

## R-007：`Products.AverageRating` 精度設計

### 決策
`Products.AverageRating DECIMAL(3,1) NOT NULL DEFAULT 0`，允許 `0.0` 到 `5.0`，精度一位小數。

### 理由
- 符合電商評分慣例（1~5 星，顯示一位小數）。
- `DECIMAL(3,1)` 整數位 2 位 + 小數 1 位，最大值 `99.9` 足夠，避免 FLOAT 浮點誤差。

---

## 結論

所有研究議題均已解決，無殘留 NEEDS CLARIFICATION。可進入 Phase 1 資料模型設計。
