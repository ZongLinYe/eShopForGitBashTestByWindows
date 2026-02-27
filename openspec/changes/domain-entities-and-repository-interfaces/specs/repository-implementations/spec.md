## ADDED Requirements

### Requirement: 所有 Repository 查詢方法含軟刪除過濾
系統 SHALL 在每個 Repository 的查詢方法中明確加上 `.Where(x => !x.IsDeleted)` 條件（適用於含 `IsDeleted` 欄位的資料表：Users、Categories、Products、Orders）。

#### Scenario: 查詢時自動排除軟刪除資料
- **WHEN** 呼叫任何 Repository 的 `GetById`、`GetAll`、`GetByXxx` 方法
- **THEN** SHALL 不回傳 `IsDeleted = 1` 的資料列

#### Scenario: Banner 與 TwoFactorToken 不適用軟刪除過濾
- **WHEN** 呼叫 `BannerRepository` 或 `TwoFactorTokenRepository` 的查詢方法
- **THEN** SHALL 不加上 `IsDeleted` 過濾（兩張表無此欄位）

---

### Requirement: 需關聯資料的查詢方法使用 .Include() 明確載入
系統 SHALL 在 Repository 方法中以 `.Include()` 明確指定需要載入的導覽屬性，禁止在 Repository 外部觸發 Lazy Load。

#### Scenario: GetByIdWithItems 一次性載入 OrderItems
- **WHEN** 呼叫 `OrderRepository.GetByIdWithItems(orderId)`
- **THEN** SHALL 回傳的 `Order` 物件中 `OrderItems` 集合已載入，不觸發額外 SQL

#### Scenario: GetByCategory 不預設載入 Category 導覽屬性
- **WHEN** 呼叫 `ProductRepository.GetByCategory(categoryId, page, pageSize)`
- **THEN** 回傳的 `Product` 集合 SHALL NOT 含已載入的 `Category` 導覽屬性（避免不必要的 JOIN）

---

### Requirement: UserRepository 實作
系統 SHALL 提供 `UserRepository` 實作 `IUserRepository`，以 `EShopDbContext` 存取資料。

#### Scenario: GetByUsername 回傳指定使用者
- **WHEN** 以有效 `username` 呼叫 `GetByUsername`
- **THEN** SHALL 回傳對應未刪除的 `User`；若不存在則回傳 `null`

#### Scenario: GetByEmail 回傳指定使用者
- **WHEN** 以有效 `email` 呼叫 `GetByEmail`
- **THEN** SHALL 回傳對應未刪除的 `User`；若不存在則回傳 `null`

---

### Requirement: CategoryRepository 實作
系統 SHALL 提供 `CategoryRepository` 實作 `ICategoryRepository`。

#### Scenario: GetAll 回傳所有未刪除分類，依 DisplayOrder 排序
- **WHEN** 呼叫 `GetAll`
- **THEN** SHALL 回傳所有 `IsDeleted = 0` 的分類，依 `DisplayOrder` 升冪排列

---

### Requirement: ProductRepository 實作
系統 SHALL 提供 `ProductRepository` 實作 `IProductRepository`。

#### Scenario: GetByCategory 回傳分頁商品清單
- **WHEN** 以 `categoryId`、`page`（1-based）、`pageSize` 呼叫 `GetByCategory`
- **THEN** SHALL 回傳對應分類、指定頁碼、未刪除的商品清單

#### Scenario: GetBestSellers 回傳高評分商品
- **WHEN** 呼叫 `GetBestSellers(count)`
- **THEN** SHALL 依 `AverageRating` 降冪取前 `count` 筆未刪除商品

---

### Requirement: BannerRepository 實作
系統 SHALL 提供 `BannerRepository` 實作 `IBannerRepository`。

#### Scenario: GetActiveOrdered 回傳啟用中的 Banner
- **WHEN** 呼叫 `GetActiveOrdered`
- **THEN** SHALL 回傳所有 `IsActive = 1` 的 Banner，依 `DisplayOrder` 升冪排列

---

### Requirement: OrderRepository 實作
系統 SHALL 提供 `OrderRepository` 實作 `IOrderRepository`。

#### Scenario: GetByUserId 回傳使用者訂單清單
- **WHEN** 以有效 `userId`、`page`、`pageSize` 呼叫 `GetByUserId`
- **THEN** SHALL 回傳該使用者的訂單，依 `CreatedAt` 降冪（最新在上）

#### Scenario: GetByIdWithItems 回傳訂單含明細
- **WHEN** 以有效 `orderId` 呼叫 `GetByIdWithItems`
- **THEN** SHALL 回傳 `Order` 物件且 `OrderItems` 集合已透過 `.Include()` 載入
