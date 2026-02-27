## ADDED Requirements

### Requirement: EShopDbContext 繼承 DbContext 並宣告所有 DbSet
系統 SHALL 在 `eShop.Repositories/Data/EShopDbContext.cs` 定義 `EShopDbContext`，繼承 EF6 `DbContext`，宣告 7 個 `DbSet<T>`。

#### Scenario: EShopDbContext 接受連線字串建構
- **WHEN** 以連線字串名稱（`"eShopDB"`）實例化 `EShopDbContext`
- **THEN** SHALL 成功建立並可對資料庫執行查詢

#### Scenario: EShopDbContext 宣告所有 DbSet
- **WHEN** 開發者參照 `EShopDbContext`
- **THEN** SHALL 包含 `DbSet<User> Users`、`DbSet<TwoFactorToken> TwoFactorTokens`、`DbSet<Category> Categories`、`DbSet<Product> Products`、`DbSet<Banner> Banners`、`DbSet<Order> Orders`、`DbSet<OrderItem> OrderItems`

---

### Requirement: OnModelCreating 設定表名映射
系統 SHALL 在 `OnModelCreating` 中明確設定 Entity 對應的資料表名稱（因部分 Entity 名稱與資料表複數名稱不一致）。

#### Scenario: Entity 正確映射至對應資料表
- **WHEN** EF6 產生 SQL
- **THEN** `User` SHALL 映射至 `dbo.Users`、`TwoFactorToken` 映射至 `dbo.TwoFactorTokens`、`Category` 映射至 `dbo.Categories`、`Product` 映射至 `dbo.Products`、`Banner` 映射至 `dbo.Banners`、`Order` 映射至 `dbo.Orders`、`OrderItem` 映射至 `dbo.OrderItems`

---

### Requirement: EShopDbContext 不設定全域軟刪除過濾
系統 SHALL NOT 在 `EShopDbContext` 使用 EF6 攔截器或 Global Query Filter 自動過濾 `IsDeleted`，軟刪除過濾由各 Repository 方法明確處理。

#### Scenario: DbContext 不包含軟刪除攔截器
- **WHEN** 開發者檢視 `EShopDbContext` 程式碼
- **THEN** SHALL NOT 存在任何 `IDbCommandInterceptor` 或自動注入 `WHERE IsDeleted = 0` 的機制
