# Data Model: 新增資料庫建立腳本

**Phase 1 Output** | **Branch**: `001-db-init-script` | **Date**: 2026-02-27

---

## 資料庫總覽

- **資料庫名稱**: `eShopDB`
- **資料表數量**: 7 張
- **關聯圖**：

```
Users ──┬──< TwoFactorTokens
        │
        └──< Orders ──< OrderItems >── Products >── Categories
```

---

## 資料表定義

### 1. `Users`（會員帳號）

| 欄位名稱 | 型別 | 可空 | 預設值 | 說明 |
|---------|------|------|--------|------|
| `Id` | `INT IDENTITY(1,1)` | NOT NULL | — | 主鍵 |
| `Username` | `NVARCHAR(50)` | NOT NULL | — | 登入帳號（唯一） |
| `Email` | `NVARCHAR(200)` | NOT NULL | — | 電子郵件（唯一） |
| `PasswordHash` | `NVARCHAR(500)` | NOT NULL | — | PBKDF2 雜湊（Base64） |
| `PasswordSalt` | `NVARCHAR(200)` | NOT NULL | — | 隨機鹽（Base64） |
| `Role` | `NVARCHAR(20)` | NOT NULL | — | 角色字串：`Member` / `VipMember` / `Admin` / `SuperAdmin` |
| `IsEmailVerified` | `BIT` | NOT NULL | `0` | Email 驗證狀態 |
| `TwoFactorMethod` | `INT` | NOT NULL | `0` | 0=Email OTP, 1=TOTP |
| `TotpSecret` | `NVARCHAR(200)` | NULL | `NULL` | TOTP 密鑰（綁定後儲存） |
| `CreatedAt` | `DATETIME2` | NOT NULL | `GETUTCDATE()` | 建立時間 |
| `UpdatedAt` | `DATETIME2` | NOT NULL | `GETUTCDATE()` | 最後更新時間 |
| `IsDeleted` | `BIT` | NOT NULL | `0` | 軟刪除旗標 |

**索引**: `UQ_Users_Username`（唯一）、`UQ_Users_Email`（唯一）

**驗證規則**:
- `Username` 長度 3–50 字元，僅允許英數字與底線
- `Email` 符合 Email 格式
- `Role` 必須為四種角色值之一

---

### 2. `TwoFactorTokens`（雙因素驗證碼）

| 欄位名稱 | 型別 | 可空 | 預設值 | 說明 |
|---------|------|------|--------|------|
| `Id` | `INT IDENTITY(1,1)` | NOT NULL | — | 主鍵 |
| `UserId` | `INT` | NOT NULL | — | 外鍵 → `Users.Id` |
| `Token` | `NVARCHAR(6)` | NOT NULL | — | 6 位數字驗證碼 |
| `ExpiresAt` | `DATETIME2` | NOT NULL | — | 有效期限（UTC，插入時 +5 分鐘） |
| `IsUsed` | `BIT` | NOT NULL | `0` | 是否已使用 |
| `CreatedAt` | `DATETIME2` | NOT NULL | `GETUTCDATE()` | 建立時間 |

**外鍵**: `FK_TwoFactorTokens_Users`（`UserId` → `Users.Id`，CASCADE DELETE）

**驗證規則**:
- `Token` 必須為 6 位純數字字串
- 驗證時須同時檢查 `ExpiresAt > GETUTCDATE()` 且 `IsUsed = 0`

---

### 3. `Categories`（商品分類）

| 欄位名稱 | 型別 | 可空 | 預設值 | 說明 |
|---------|------|------|--------|------|
| `Id` | `INT IDENTITY(1,1)` | NOT NULL | — | 主鍵 |
| `Name` | `NVARCHAR(100)` | NOT NULL | — | 分類名稱 |
| `Slug` | `NVARCHAR(100)` | NOT NULL | — | URL 識別別名（唯一，英文小寫連字號） |
| `IconUrl` | `NVARCHAR(500)` | NULL | `NULL` | 分類圖示路徑 |
| `DisplayOrder` | `INT` | NOT NULL | `0` | 前端顯示排序 |
| `CreatedAt` | `DATETIME2` | NOT NULL | `GETUTCDATE()` | 建立時間 |
| `UpdatedAt` | `DATETIME2` | NOT NULL | `GETUTCDATE()` | 最後更新時間 |
| `IsDeleted` | `BIT` | NOT NULL | `0` | 軟刪除旗標 |

**索引**: `UQ_Categories_Slug`（唯一）

---

### 4. `Products`（商品）

| 欄位名稱 | 型別 | 可空 | 預設值 | 說明 |
|---------|------|------|--------|------|
| `Id` | `INT IDENTITY(1,1)` | NOT NULL | — | 主鍵 |
| `Name` | `NVARCHAR(200)` | NOT NULL | — | 商品名稱 |
| `Description` | `NVARCHAR(MAX)` | NULL | `NULL` | 商品描述 |
| `Price` | `DECIMAL(18,2)` | NOT NULL | — | 售價 |
| `StockQuantity` | `INT` | NOT NULL | `0` | 庫存數量 |
| `ImageUrl` | `NVARCHAR(500)` | NULL | `NULL` | 商品圖片路徑 |
| `CategoryId` | `INT` | NOT NULL | — | 外鍵 → `Categories.Id` |
| `AverageRating` | `DECIMAL(3,1)` | NOT NULL | `0` | 平均評分（0.0–5.0） |
| `ReviewCount` | `INT` | NOT NULL | `0` | 評論總數 |
| `CreatedAt` | `DATETIME2` | NOT NULL | `GETUTCDATE()` | 建立時間 |
| `UpdatedAt` | `DATETIME2` | NOT NULL | `GETUTCDATE()` | 最後更新時間 |
| `IsDeleted` | `BIT` | NOT NULL | `0` | 軟刪除旗標 |

**外鍵**: `FK_Products_Categories`（`CategoryId` → `Categories.Id`，RESTRICT）

**驗證規則**:
- `Price` > 0
- `StockQuantity` >= 0
- `AverageRating` 介於 0.0 到 5.0

---

### 5. `Banners`（首頁輪播廣告）

| 欄位名稱 | 型別 | 可空 | 預設值 | 說明 |
|---------|------|------|--------|------|
| `Id` | `INT IDENTITY(1,1)` | NOT NULL | — | 主鍵 |
| `Title` | `NVARCHAR(200)` | NOT NULL | — | 廣告標題 |
| `Subtitle` | `NVARCHAR(500)` | NULL | `NULL` | 廣告副標題 |
| `ImageUrl` | `NVARCHAR(500)` | NOT NULL | — | 廣告圖片路徑 |
| `ButtonText` | `NVARCHAR(50)` | NULL | `NULL` | 按鈕文字 |
| `ButtonUrl` | `NVARCHAR(500)` | NULL | `NULL` | 按鈕連結 |
| `DisplayOrder` | `INT` | NOT NULL | `0` | 輪播顯示排序 |
| `IsActive` | `BIT` | NOT NULL | `1` | 是否啟用 |
| `CreatedAt` | `DATETIME2` | NOT NULL | `GETUTCDATE()` | 建立時間 |
| `UpdatedAt` | `DATETIME2` | NOT NULL | `GETUTCDATE()` | 最後更新時間 |

---

### 6. `Orders`（訂單）

| 欄位名稱 | 型別 | 可空 | 預設值 | 說明 |
|---------|------|------|--------|------|
| `Id` | `INT IDENTITY(1,1)` | NOT NULL | — | 主鍵 |
| `UserId` | `INT` | NOT NULL | — | 外鍵 → `Users.Id` |
| `TotalAmount` | `DECIMAL(18,2)` | NOT NULL | — | 訂單總金額 |
| `RecipientName` | `NVARCHAR(100)` | NOT NULL | — | 收件人姓名 |
| `RecipientEmail` | `NVARCHAR(200)` | NOT NULL | — | 收件人 Email |
| `RecipientPhone` | `NVARCHAR(20)` | NOT NULL | — | 收件人電話 |
| `ShippingAddress` | `NVARCHAR(500)` | NOT NULL | — | 收件地址 |
| `Status` | `INT` | NOT NULL | `0` | 訂單狀態（enum）：0=Pending, 1=Confirmed, 2=Shipped, 3=Delivered, 4=Cancelled |
| `Note` | `NVARCHAR(500)` | NULL | `NULL` | 訂單備註 |
| `CreatedAt` | `DATETIME2` | NOT NULL | `GETUTCDATE()` | 建立時間 |
| `UpdatedAt` | `DATETIME2` | NOT NULL | `GETUTCDATE()` | 最後更新時間 |

**外鍵**: `FK_Orders_Users`（`UserId` → `Users.Id`，RESTRICT）

---

### 7. `OrderItems`（訂單明細）

| 欄位名稱 | 型別 | 可空 | 預設值 | 說明 |
|---------|------|------|--------|------|
| `Id` | `INT IDENTITY(1,1)` | NOT NULL | — | 主鍵 |
| `OrderId` | `INT` | NOT NULL | — | 外鍵 → `Orders.Id` |
| `ProductId` | `INT` | NULL | `NULL` | 外鍵 → `Products.Id`（允許 NULL：商品刪除後仍保留快照） |
| `ProductName` | `NVARCHAR(200)` | NOT NULL | — | 下單當下商品名稱快照 |
| `UnitPrice` | `DECIMAL(18,2)` | NOT NULL | — | 下單當下商品單價快照 |
| `Quantity` | `INT` | NOT NULL | — | 購買數量 |
| `CreatedAt` | `DATETIME2` | NOT NULL | `GETUTCDATE()` | 建立時間 |

**外鍵**:
- `FK_OrderItems_Orders`（`OrderId` → `Orders.Id`，CASCADE DELETE）
- `FK_OrderItems_Products`（`ProductId` → `Products.Id`，SET NULL）

**驗證規則**:
- `Quantity` >= 1
- `UnitPrice` >= 0

---

## 種子資料規格

### 分類種子（4 筆）

| Id | Name | Slug | DisplayOrder |
|----|------|------|-------------|
| 1 | Fine Jewelry | fine-jewelry | 1 |
| 2 | Beauty | beauty | 2 |
| 3 | Home Decor | home-decor | 3 |
| 4 | Lifestyle | lifestyle | 4 |

### 商品種子（8 筆）

| 商品名稱 | 分類 | 售價 | 庫存 |
|---------|------|------|------|
| Rose Gold Necklace | Fine Jewelry | 3,580 | 50 |
| Diamond Stud Earrings | Fine Jewelry | 8,980 | 20 |
| Velvet Lip Tint | Beauty | 680 | 200 |
| Glow Serum | Beauty | 1,280 | 150 |
| Linen Candle | Home Decor | 880 | 100 |
| Ceramic Vase | Home Decor | 1,580 | 60 |
| Leather Tote Bag | Lifestyle | 4,980 | 30 |
| Silk Scarf | Lifestyle | 2,280 | 45 |

### Banner 種子（2 筆）

| 標題 | 副標題 | 顯示排序 |
|------|--------|---------|
| Lumina & Bloom | Discover timeless elegance | 1 |
| New Arrivals | Spring collection is here | 2 |

### 管理員帳號種子（1 筆）

| 欄位 | 值 |
|------|-----|
| Username | `admin` |
| Email | `admin@eshop.local` |
| Role | `Admin` |
| IsEmailVerified | `1` |
| TwoFactorMethod | `0`（Email OTP） |

---

## 狀態機

### 訂單狀態（`Orders.Status`）

```
Pending(0) → Confirmed(1) → Shipped(2) → Delivered(3)
         ↘                ↘             ↘
          Cancelled(4)     Cancelled(4)  Cancelled(4)
```

### 雙因素驗證方式（`Users.TwoFactorMethod`）

```
Email(0) ←→ Totp(1)   （可在會員設定頁切換）
```
