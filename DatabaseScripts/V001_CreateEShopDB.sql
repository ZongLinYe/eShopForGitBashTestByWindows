-- =============================================================================
-- 版本:     V001
-- 腳本名稱: V001_CreateEShopDB.sql
-- 建立日期: 2026-02-27
-- 說明:     建立 eShopDB 資料庫、7 張主要資料表、所有外鍵關聯，
--           並填入種子資料（4 分類、8 商品、2 Banner、1 管理員帳號）。
--           採冪等性設計（IF NOT EXISTS），可在任何環境重複執行。
-- 執行方式: 請參閱 specs/001-db-init-script/quickstart.md
-- 測試帳號: admin / Admin@123456（開發測試專用，禁止用於正式環境）
-- =============================================================================

USE master;
GO

-- =============================================================================
-- 建立 eShopDB 資料庫（冪等：若已存在則跳過）
-- =============================================================================
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'eShopDB')
BEGIN
    CREATE DATABASE eShopDB;
END
GO

USE eShopDB;
GO

-- =============================================================================
-- 建立 Users（會員帳號）資料表
-- =============================================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES
               WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Users')
BEGIN
    CREATE TABLE dbo.Users
    (
        Id               INT            IDENTITY(1,1)  NOT NULL,
        Username         NVARCHAR(50)                  NOT NULL,
        Email            NVARCHAR(200)                 NOT NULL,
        PasswordHash     NVARCHAR(500)                 NOT NULL,
        PasswordSalt     NVARCHAR(200)                 NOT NULL,
        Role             NVARCHAR(20)                  NOT NULL,
        IsEmailVerified  BIT                           NOT NULL  DEFAULT 0,
        TwoFactorMethod  INT                           NOT NULL  DEFAULT 0,
        TotpSecret       NVARCHAR(200)                 NULL,
        CreatedAt        DATETIME2                     NOT NULL  DEFAULT GETUTCDATE(),
        UpdatedAt        DATETIME2                     NOT NULL  DEFAULT GETUTCDATE(),
        IsDeleted        BIT                           NOT NULL  DEFAULT 0,
        CONSTRAINT PK_Users PRIMARY KEY (Id)
    );

    -- 使用者名稱唯一索引
    CREATE UNIQUE INDEX UQ_Users_Username ON dbo.Users (Username);
    -- 電子郵件唯一索引
    CREATE UNIQUE INDEX UQ_Users_Email    ON dbo.Users (Email);

    -- 資料表說明
    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description', @value = N'會員帳號資料表，儲存系統所有使用者的基本資料、密碼雜湊及角色資訊',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE',  @level1name = N'Users';

    -- 欄位說明
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'主鍵，自動遞增整數',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Users', @level2type = N'COLUMN', @level2name = N'Id';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'登入帳號（唯一），3–50 字元，僅允許英數字與底線',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Users', @level2type = N'COLUMN', @level2name = N'Username';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'電子郵件地址（唯一），格式須符合 Email 規範',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Users', @level2type = N'COLUMN', @level2name = N'Email';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'密碼 PBKDF2-SHA256 雜湊值（Base64 編碼），310,000 次迭代',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Users', @level2type = N'COLUMN', @level2name = N'PasswordHash';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'密碼加鹽值（Base64 編碼，128-bit 隨機產生）',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Users', @level2type = N'COLUMN', @level2name = N'PasswordSalt';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'使用者角色：Member / VipMember / Admin / SuperAdmin',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Users', @level2type = N'COLUMN', @level2name = N'Role';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'Email 驗證狀態：0=未驗證, 1=已驗證',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Users', @level2type = N'COLUMN', @level2name = N'IsEmailVerified';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'雙因素驗證方式：0=Email OTP, 1=TOTP',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Users', @level2type = N'COLUMN', @level2name = N'TwoFactorMethod';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'TOTP 應用程式綁定後的密鑰（可為 NULL，未啟用時留空）',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Users', @level2type = N'COLUMN', @level2name = N'TotpSecret';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'記錄建立時間（UTC）',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Users', @level2type = N'COLUMN', @level2name = N'CreatedAt';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'最後更新時間（UTC），每次 UPDATE 應同步修改',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Users', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'軟刪除旗標：0=正常, 1=已刪除（禁止直接 DELETE 資料列）',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Users', @level2type = N'COLUMN', @level2name = N'IsDeleted';
END
GO

-- =============================================================================
-- 建立 TwoFactorTokens（雙因素驗證碼）資料表
-- =============================================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES
               WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'TwoFactorTokens')
BEGIN
    CREATE TABLE dbo.TwoFactorTokens
    (
        Id        INT           IDENTITY(1,1)  NOT NULL,
        UserId    INT                          NOT NULL,
        Token     NVARCHAR(6)                  NOT NULL,
        ExpiresAt DATETIME2                    NOT NULL,
        IsUsed    BIT                          NOT NULL  DEFAULT 0,
        CreatedAt DATETIME2                    NOT NULL  DEFAULT GETUTCDATE(),
        CONSTRAINT PK_TwoFactorTokens PRIMARY KEY (Id)
    );

    -- 資料表說明
    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description', @value = N'雙因素驗證碼資料表，儲存 Email OTP 一次性驗證碼及其有效期限',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE',  @level1name = N'TwoFactorTokens';

    -- 欄位說明
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'主鍵，自動遞增整數',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TwoFactorTokens', @level2type = N'COLUMN', @level2name = N'Id';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'外鍵對應 Users.Id，擁有此驗證碼的使用者',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TwoFactorTokens', @level2type = N'COLUMN', @level2name = N'UserId';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'6 位數字驗證碼（字串格式，保留前導零）',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TwoFactorTokens', @level2type = N'COLUMN', @level2name = N'Token';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'驗證碼有效期限（UTC），通常為建立時間 +5 分鐘',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TwoFactorTokens', @level2type = N'COLUMN', @level2name = N'ExpiresAt';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'是否已使用：0=未使用, 1=已使用（使用後立即標記，防止重放攻擊）',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TwoFactorTokens', @level2type = N'COLUMN', @level2name = N'IsUsed';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'記錄建立時間（UTC）',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TwoFactorTokens', @level2type = N'COLUMN', @level2name = N'CreatedAt';
END
GO

-- =============================================================================
-- 建立 Categories（商品分類）資料表
-- =============================================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES
               WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Categories')
BEGIN
    CREATE TABLE dbo.Categories
    (
        Id           INT            IDENTITY(1,1)  NOT NULL,
        Name         NVARCHAR(100)                 NOT NULL,
        Slug         NVARCHAR(100)                 NOT NULL,
        IconUrl      NVARCHAR(500)                 NULL,
        DisplayOrder INT                           NOT NULL  DEFAULT 0,
        CreatedAt    DATETIME2                     NOT NULL  DEFAULT GETUTCDATE(),
        UpdatedAt    DATETIME2                     NOT NULL  DEFAULT GETUTCDATE(),
        IsDeleted    BIT                           NOT NULL  DEFAULT 0,
        CONSTRAINT PK_Categories PRIMARY KEY (Id)
    );

    -- Slug 唯一索引（URL 識別別名不可重複）
    CREATE UNIQUE INDEX UQ_Categories_Slug ON dbo.Categories (Slug);

    -- 資料表說明
    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description', @value = N'商品分類資料表，用於前台導覽列與商品篩選，支援軟刪除',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE',  @level1name = N'Categories';

    -- 欄位說明
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'主鍵，自動遞增整數',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Categories', @level2type = N'COLUMN', @level2name = N'Id';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'分類顯示名稱，例如「Fine Jewelry」',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Categories', @level2type = N'COLUMN', @level2name = N'Name';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'URL 識別別名（唯一），英文小寫連字號格式，例如「fine-jewelry」',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Categories', @level2type = N'COLUMN', @level2name = N'Slug';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'分類圖示的相對路徑或 URL（可為 NULL，未設定時不顯示圖示）',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Categories', @level2type = N'COLUMN', @level2name = N'IconUrl';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'前端導覽列顯示排序（數字越小越前面）',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Categories', @level2type = N'COLUMN', @level2name = N'DisplayOrder';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'記錄建立時間（UTC）',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Categories', @level2type = N'COLUMN', @level2name = N'CreatedAt';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'最後更新時間（UTC），每次 UPDATE 應同步修改',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Categories', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'軟刪除旗標：0=正常, 1=已刪除（禁止直接 DELETE 資料列）',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Categories', @level2type = N'COLUMN', @level2name = N'IsDeleted';
END
GO

-- =============================================================================
-- 建立 Products（商品）資料表
-- =============================================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES
               WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Products')
BEGIN
    CREATE TABLE dbo.Products
    (
        Id            INT              IDENTITY(1,1)  NOT NULL,
        Name          NVARCHAR(200)                   NOT NULL,
        Description   NVARCHAR(MAX)                   NULL,
        Price         DECIMAL(18,2)                   NOT NULL,
        StockQuantity INT                             NOT NULL  DEFAULT 0,
        ImageUrl      NVARCHAR(500)                   NULL,
        CategoryId    INT                             NOT NULL,
        AverageRating DECIMAL(3,1)                    NOT NULL  DEFAULT 0,
        ReviewCount   INT                             NOT NULL  DEFAULT 0,
        CreatedAt     DATETIME2                       NOT NULL  DEFAULT GETUTCDATE(),
        UpdatedAt     DATETIME2                       NOT NULL  DEFAULT GETUTCDATE(),
        IsDeleted     BIT                             NOT NULL  DEFAULT 0,
        CONSTRAINT PK_Products PRIMARY KEY (Id)
    );

    -- 資料表說明
    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description', @value = N'商品資料表，儲存上架商品的基本資訊、定價、庫存與分類對應，支援軟刪除',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE',  @level1name = N'Products';

    -- 欄位說明
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'主鍵，自動遞增整數',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Products', @level2type = N'COLUMN', @level2name = N'Id';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'商品名稱，前台顯示用',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Products', @level2type = N'COLUMN', @level2name = N'Name';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'商品詳細描述（可為 NULL，支援 HTML 或長文），顯示於商品詳情頁',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Products', @level2type = N'COLUMN', @level2name = N'Description';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'商品售價（需大於 0），幣別為新台幣',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Products', @level2type = N'COLUMN', @level2name = N'Price';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'目前庫存數量（需大於等於 0），下訂單時須扣減',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Products', @level2type = N'COLUMN', @level2name = N'StockQuantity';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'商品主圖的相對路徑或 URL（可為 NULL，未設定時顯示預設圖片）',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Products', @level2type = N'COLUMN', @level2name = N'ImageUrl';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'外鍵對應 Categories.Id，商品所屬分類',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Products', @level2type = N'COLUMN', @level2name = N'CategoryId';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'平均評分（0.0–5.0），由評論系統自動計算更新',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Products', @level2type = N'COLUMN', @level2name = N'AverageRating';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'評論總數，與 AverageRating 同步更新',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Products', @level2type = N'COLUMN', @level2name = N'ReviewCount';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'記錄建立時間（UTC）',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Products', @level2type = N'COLUMN', @level2name = N'CreatedAt';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'最後更新時間（UTC），每次 UPDATE 應同步修改',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Products', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'軟刪除旗標：0=正常, 1=已刪除（禁止直接 DELETE 資料列）',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Products', @level2type = N'COLUMN', @level2name = N'IsDeleted';
END
GO

-- =============================================================================
-- 建立 Banners（首頁輪播廣告）資料表
-- =============================================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES
               WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Banners')
BEGIN
    CREATE TABLE dbo.Banners
    (
        Id           INT           IDENTITY(1,1)  NOT NULL,
        Title        NVARCHAR(200)                NOT NULL,
        Subtitle     NVARCHAR(500)                NULL,
        ImageUrl     NVARCHAR(500)                NOT NULL,
        ButtonText   NVARCHAR(50)                 NULL,
        ButtonUrl    NVARCHAR(500)                NULL,
        DisplayOrder INT                          NOT NULL  DEFAULT 0,
        IsActive     BIT                          NOT NULL  DEFAULT 1,
        CreatedAt    DATETIME2                    NOT NULL  DEFAULT GETUTCDATE(),
        UpdatedAt    DATETIME2                    NOT NULL  DEFAULT GETUTCDATE(),
        CONSTRAINT PK_Banners PRIMARY KEY (Id)
    );

    -- 資料表說明
    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description', @value = N'首頁輪播廣告資料表，儲存 Banner 的圖片、文案與連結設定',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE',  @level1name = N'Banners';

    -- 欄位說明
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'主鍵，自動遞增整數',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Banners', @level2type = N'COLUMN', @level2name = N'Id';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'廣告主標題，顯示於 Banner 圖片上',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Banners', @level2type = N'COLUMN', @level2name = N'Title';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'廣告副標題（可為 NULL），顯示於主標題下方',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Banners', @level2type = N'COLUMN', @level2name = N'Subtitle';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'廣告圖片的相對路徑或 URL，建議尺寸依前端設計規格',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Banners', @level2type = N'COLUMN', @level2name = N'ImageUrl';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'行動呼籲按鈕文字（可為 NULL），例如「立即選購」',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Banners', @level2type = N'COLUMN', @level2name = N'ButtonText';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'行動呼籲按鈕連結 URL（可為 NULL），點擊後跳轉目標頁面',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Banners', @level2type = N'COLUMN', @level2name = N'ButtonUrl';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'輪播顯示排序（數字越小越前面）',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Banners', @level2type = N'COLUMN', @level2name = N'DisplayOrder';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'是否啟用：0=停用（不顯示於前台）, 1=啟用',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Banners', @level2type = N'COLUMN', @level2name = N'IsActive';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'記錄建立時間（UTC）',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Banners', @level2type = N'COLUMN', @level2name = N'CreatedAt';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'最後更新時間（UTC），每次 UPDATE 應同步修改',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Banners', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
END
GO

-- =============================================================================
-- 建立 Orders（訂單）資料表
-- =============================================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES
               WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Orders')
BEGIN
    CREATE TABLE dbo.Orders
    (
        Id              INT            IDENTITY(1,1)  NOT NULL,
        UserId          INT                           NOT NULL,
        TotalAmount     DECIMAL(18,2)                 NOT NULL,
        RecipientName   NVARCHAR(100)                 NOT NULL,
        RecipientEmail  NVARCHAR(200)                 NOT NULL,
        RecipientPhone  NVARCHAR(20)                  NOT NULL,
        ShippingAddress NVARCHAR(500)                 NOT NULL,
        -- 訂單狀態：0=Pending, 1=Confirmed, 2=Shipped, 3=Delivered, 4=Cancelled
        Status          INT                           NOT NULL  DEFAULT 0,
        Note            NVARCHAR(500)                 NULL,
        CreatedAt       DATETIME2                     NOT NULL  DEFAULT GETUTCDATE(),
        UpdatedAt       DATETIME2                     NOT NULL  DEFAULT GETUTCDATE(),
        CONSTRAINT PK_Orders PRIMARY KEY (Id)
    );

    -- 資料表說明
    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description', @value = N'訂單主檔資料表，記錄每筆訂單的總金額、收件人資訊與目前狀態',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE',  @level1name = N'Orders';

    -- 欄位說明
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'主鍵，自動遞增整數',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'Id';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'外鍵對應 Users.Id，下訂單的會員',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'UserId';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'訂單總金額（所有訂單明細的 UnitPrice × Quantity 加總），幣別為新台幣',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'TotalAmount';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'收件人姓名（快照，允許與帳號姓名不同）',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'RecipientName';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'收件人電子郵件（快照，用於寄送出貨通知）',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'RecipientEmail';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'收件人聯絡電話（快照）',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'RecipientPhone';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'收件地址（快照，完整地址含縣市、郵遞區號）',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'ShippingAddress';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'訂單狀態：0=Pending（待確認）, 1=Confirmed（已確認）, 2=Shipped（已出貨）, 3=Delivered（已送達）, 4=Cancelled（已取消）',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'Status';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'訂單備註（可為 NULL），顧客下單時填寫的特殊需求',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'Note';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'記錄建立時間（UTC）',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'CreatedAt';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'最後更新時間（UTC），訂單狀態異動時應同步修改',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Orders', @level2type = N'COLUMN', @level2name = N'UpdatedAt';
END
GO

-- =============================================================================
-- 建立 OrderItems（訂單明細）資料表
-- =============================================================================
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES
               WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'OrderItems')
BEGIN
    CREATE TABLE dbo.OrderItems
    (
        Id          INT            IDENTITY(1,1)  NOT NULL,
        OrderId     INT                           NOT NULL,
        -- ProductId 允許 NULL：商品刪除後保留快照，外鍵設為 SET NULL
        ProductId   INT                           NULL,
        ProductName NVARCHAR(200)                 NOT NULL,
        UnitPrice   DECIMAL(18,2)                 NOT NULL,
        Quantity    INT                           NOT NULL,
        CreatedAt   DATETIME2                     NOT NULL  DEFAULT GETUTCDATE(),
        CONSTRAINT PK_OrderItems PRIMARY KEY (Id)
    );

    -- 資料表說明
    EXEC sys.sp_addextendedproperty
        @name = N'MS_Description', @value = N'訂單明細資料表，記錄每筆訂單包含的商品快照（商品刪除後仍保留歷史記錄）',
        @level0type = N'SCHEMA', @level0name = N'dbo',
        @level1type = N'TABLE',  @level1name = N'OrderItems';

    -- 欄位說明
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'主鍵，自動遞增整數',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OrderItems', @level2type = N'COLUMN', @level2name = N'Id';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'外鍵對應 Orders.Id，此明細所屬的訂單（訂單刪除時同步刪除）',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OrderItems', @level2type = N'COLUMN', @level2name = N'OrderId';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'外鍵對應 Products.Id（允許 NULL）：商品被刪除後設為 NULL，但 ProductName/UnitPrice 快照仍保留',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OrderItems', @level2type = N'COLUMN', @level2name = N'ProductId';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'下單當下商品名稱快照，即使商品改名後歷史訂單仍顯示原名',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OrderItems', @level2type = N'COLUMN', @level2name = N'ProductName';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'下單當下商品單價快照（需大於等於 0），即使售價調整後歷史訂單仍顯示原價',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OrderItems', @level2type = N'COLUMN', @level2name = N'UnitPrice';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'購買數量（需大於等於 1）',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OrderItems', @level2type = N'COLUMN', @level2name = N'Quantity';
    EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = N'記錄建立時間（UTC）',
        @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OrderItems', @level2type = N'COLUMN', @level2name = N'CreatedAt';
END
GO

-- =============================================================================
-- 建立外鍵約束（5 條，冪等：以 OBJECT_ID 守衛避免重複建立）
-- =============================================================================

-- FK1: TwoFactorTokens.UserId → Users.Id（CASCADE DELETE）
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_TwoFactorTokens_Users')
BEGIN
    ALTER TABLE dbo.TwoFactorTokens
        ADD CONSTRAINT FK_TwoFactorTokens_Users
        FOREIGN KEY (UserId) REFERENCES dbo.Users (Id)
        ON DELETE CASCADE;
END
GO

-- FK2: Products.CategoryId → Categories.Id（RESTRICT，不可刪除有商品的分類）
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Products_Categories')
BEGIN
    ALTER TABLE dbo.Products
        ADD CONSTRAINT FK_Products_Categories
        FOREIGN KEY (CategoryId) REFERENCES dbo.Categories (Id);
END
GO

-- FK3: Orders.UserId → Users.Id（RESTRICT，不可直接刪除有訂單的會員）
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Orders_Users')
BEGIN
    ALTER TABLE dbo.Orders
        ADD CONSTRAINT FK_Orders_Users
        FOREIGN KEY (UserId) REFERENCES dbo.Users (Id);
END
GO

-- FK4: OrderItems.OrderId → Orders.Id（CASCADE DELETE）
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_OrderItems_Orders')
BEGIN
    ALTER TABLE dbo.OrderItems
        ADD CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY (OrderId) REFERENCES dbo.Orders (Id)
        ON DELETE CASCADE;
END
GO

-- FK5: OrderItems.ProductId → Products.Id（SET NULL，商品刪除後保留訂單快照）
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_OrderItems_Products')
BEGIN
    ALTER TABLE dbo.OrderItems
        ADD CONSTRAINT FK_OrderItems_Products
        FOREIGN KEY (ProductId) REFERENCES dbo.Products (Id)
        ON DELETE SET NULL;
END
GO

-- =============================================================================
-- 種子資料：4 筆商品分類（冪等：以 Name 判斷是否已存在）
-- =============================================================================

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Name = N'Fine Jewelry')
BEGIN
    INSERT INTO dbo.Categories (Name, Slug, DisplayOrder)
    VALUES (N'Fine Jewelry', N'fine-jewelry', 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Name = N'Beauty')
BEGIN
    INSERT INTO dbo.Categories (Name, Slug, DisplayOrder)
    VALUES (N'Beauty', N'beauty', 2);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Name = N'Home Decor')
BEGIN
    INSERT INTO dbo.Categories (Name, Slug, DisplayOrder)
    VALUES (N'Home Decor', N'home-decor', 3);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE Name = N'Lifestyle')
BEGIN
    INSERT INTO dbo.Categories (Name, Slug, DisplayOrder)
    VALUES (N'Lifestyle', N'lifestyle', 4);
END
GO

-- =============================================================================
-- 種子資料：8 筆商品（冪等：以 Name 判斷是否已存在）
-- =============================================================================

IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Name = N'Rose Gold Necklace')
BEGIN
    INSERT INTO dbo.Products (Name, Price, StockQuantity, CategoryId)
    SELECT N'Rose Gold Necklace', 3580.00, 50, Id
    FROM dbo.Categories WHERE Slug = N'fine-jewelry';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Name = N'Diamond Stud Earrings')
BEGIN
    INSERT INTO dbo.Products (Name, Price, StockQuantity, CategoryId)
    SELECT N'Diamond Stud Earrings', 8980.00, 20, Id
    FROM dbo.Categories WHERE Slug = N'fine-jewelry';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Name = N'Velvet Lip Tint')
BEGIN
    INSERT INTO dbo.Products (Name, Price, StockQuantity, CategoryId)
    SELECT N'Velvet Lip Tint', 680.00, 200, Id
    FROM dbo.Categories WHERE Slug = N'beauty';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Name = N'Glow Serum')
BEGIN
    INSERT INTO dbo.Products (Name, Price, StockQuantity, CategoryId)
    SELECT N'Glow Serum', 1280.00, 150, Id
    FROM dbo.Categories WHERE Slug = N'beauty';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Name = N'Linen Candle')
BEGIN
    INSERT INTO dbo.Products (Name, Price, StockQuantity, CategoryId)
    SELECT N'Linen Candle', 880.00, 100, Id
    FROM dbo.Categories WHERE Slug = N'home-decor';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Name = N'Ceramic Vase')
BEGIN
    INSERT INTO dbo.Products (Name, Price, StockQuantity, CategoryId)
    SELECT N'Ceramic Vase', 1580.00, 60, Id
    FROM dbo.Categories WHERE Slug = N'home-decor';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Name = N'Leather Tote Bag')
BEGIN
    INSERT INTO dbo.Products (Name, Price, StockQuantity, CategoryId)
    SELECT N'Leather Tote Bag', 4980.00, 30, Id
    FROM dbo.Categories WHERE Slug = N'lifestyle';
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE Name = N'Silk Scarf')
BEGIN
    INSERT INTO dbo.Products (Name, Price, StockQuantity, CategoryId)
    SELECT N'Silk Scarf', 2280.00, 45, Id
    FROM dbo.Categories WHERE Slug = N'lifestyle';
END
GO

-- =============================================================================
-- 種子資料：2 筆 Banner（冪等：以 Title 判斷是否已存在）
-- =============================================================================

IF NOT EXISTS (SELECT 1 FROM dbo.Banners WHERE Title = N'Lumina & Bloom')
BEGIN
    INSERT INTO dbo.Banners (Title, Subtitle, ImageUrl, DisplayOrder, IsActive)
    VALUES (N'Lumina & Bloom', N'Discover timeless elegance', N'/images/banners/lumina-bloom.jpg', 1, 1);
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Banners WHERE Title = N'New Arrivals')
BEGIN
    INSERT INTO dbo.Banners (Title, Subtitle, ImageUrl, DisplayOrder, IsActive)
    VALUES (N'New Arrivals', N'Spring collection is here', N'/images/banners/new-arrivals.jpg', 2, 1);
END
GO

-- =============================================================================
-- 種子資料：1 筆管理員帳號（冪等：以 Username 判斷是否已存在）
-- PBKDF2-SHA256, 310,000 次迭代, 128-bit salt（明文：Admin@123456）
-- =============================================================================

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Username = N'admin')
BEGIN
    INSERT INTO dbo.Users
        (Username, Email, PasswordHash, PasswordSalt, Role, IsEmailVerified, TwoFactorMethod)
    VALUES
    (
        N'admin',
        N'admin@eshop.local',
        N'mGOSpLRgGexzAT2XhNDcVZ3Qj5AJGcbUJjolI5TgjW4=',
        N'ag4FO8AKobY9N5bK6rApwA==',
        N'Admin',
        1,
        0
    );
END
GO
