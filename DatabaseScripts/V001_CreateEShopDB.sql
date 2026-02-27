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
