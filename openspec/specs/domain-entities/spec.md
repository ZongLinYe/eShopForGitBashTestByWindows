## ADDED Requirements

### Requirement: User Entity 對應 Users 資料表
系統 SHALL 提供 `User` Entity 類別，屬性名稱與 `dbo.Users` 資料表欄位完全一致，含 `virtual` 導覽屬性。

#### Scenario: User Entity 包含所有必要屬性
- **WHEN** 開發者參照 `User` Entity
- **THEN** SHALL 包含 `Id`、`Username`、`Email`、`PasswordHash`、`PasswordSalt`、`Role`、`IsEmailVerified`、`TwoFactorMethod`、`TotpSecret`（可為 null）、`CreatedAt`、`UpdatedAt`、`IsDeleted` 所有欄位

#### Scenario: User Entity 含導覽屬性
- **WHEN** 開發者讀取 `User.Orders` 或 `User.TwoFactorTokens`
- **THEN** SHALL 回傳對應的集合（EF6 Lazy Loading，須在 Repository 層以 `.Include()` 明確載入）

---

### Requirement: TwoFactorToken Entity 對應 TwoFactorTokens 資料表
系統 SHALL 提供 `TwoFactorToken` Entity 類別，對應 `dbo.TwoFactorTokens`。

#### Scenario: TwoFactorToken Entity 包含所有必要屬性
- **WHEN** 開發者參照 `TwoFactorToken` Entity
- **THEN** SHALL 包含 `Id`、`UserId`、`Token`、`ExpiresAt`、`IsUsed`、`CreatedAt`

#### Scenario: TwoFactorToken 含導覽屬性至 User
- **WHEN** 開發者讀取 `TwoFactorToken.User`
- **THEN** SHALL 回傳對應的 `User` Entity（EF6 Lazy Loading）

---

### Requirement: Category Entity 對應 Categories 資料表
系統 SHALL 提供 `Category` Entity 類別，對應 `dbo.Categories`，含軟刪除旗標。

#### Scenario: Category Entity 包含所有必要屬性
- **WHEN** 開發者參照 `Category` Entity
- **THEN** SHALL 包含 `Id`、`Name`、`Slug`、`IconUrl`（可為 null）、`DisplayOrder`、`CreatedAt`、`UpdatedAt`、`IsDeleted`

#### Scenario: Category 含 Products 導覽屬性
- **WHEN** 開發者讀取 `Category.Products`
- **THEN** SHALL 回傳屬於此分類的商品集合

---

### Requirement: Product Entity 對應 Products 資料表
系統 SHALL 提供 `Product` Entity 類別，對應 `dbo.Products`，含分類導覽屬性與軟刪除旗標。

#### Scenario: Product Entity 包含所有必要屬性
- **WHEN** 開發者參照 `Product` Entity
- **THEN** SHALL 包含 `Id`、`Name`、`Description`（可為 null）、`Price`、`StockQuantity`、`ImageUrl`（可為 null）、`CategoryId`、`AverageRating`、`ReviewCount`、`CreatedAt`、`UpdatedAt`、`IsDeleted`

#### Scenario: Product 含 Category 導覽屬性
- **WHEN** 開發者讀取 `Product.Category`
- **THEN** SHALL 回傳對應的 `Category` Entity

---

### Requirement: Banner Entity 對應 Banners 資料表
系統 SHALL 提供 `Banner` Entity 類別，對應 `dbo.Banners`（無軟刪除，以 `IsActive` 控制顯示）。

#### Scenario: Banner Entity 包含所有必要屬性
- **WHEN** 開發者參照 `Banner` Entity
- **THEN** SHALL 包含 `Id`、`Title`、`Subtitle`（可為 null）、`ImageUrl`、`ButtonText`（可為 null）、`ButtonUrl`（可為 null）、`DisplayOrder`、`IsActive`、`CreatedAt`、`UpdatedAt`

---

### Requirement: Order Entity 對應 Orders 資料表
系統 SHALL 提供 `Order` Entity 類別，對應 `dbo.Orders`，含訂單明細導覽屬性。

#### Scenario: Order Entity 包含所有必要屬性
- **WHEN** 開發者參照 `Order` Entity
- **THEN** SHALL 包含 `Id`、`UserId`、`TotalAmount`、`RecipientName`、`RecipientEmail`、`RecipientPhone`、`ShippingAddress`、`Status`（型別為 `OrderStatus` enum）、`Note`（可為 null）、`CreatedAt`、`UpdatedAt`

#### Scenario: Order 含 User 與 OrderItems 導覽屬性
- **WHEN** 開發者讀取 `Order.User` 或 `Order.OrderItems`
- **THEN** SHALL 分別回傳對應的 `User` 與 `OrderItem` 集合

---

### Requirement: OrderItem Entity 對應 OrderItems 資料表
系統 SHALL 提供 `OrderItem` Entity 類別，對應 `dbo.OrderItems`，含商品名稱快照欄位。

#### Scenario: OrderItem Entity 包含所有必要屬性
- **WHEN** 開發者參照 `OrderItem` Entity
- **THEN** SHALL 包含 `Id`、`OrderId`、`ProductId`（可為 null）、`ProductName`、`UnitPrice`、`Quantity`、`CreatedAt`

#### Scenario: OrderItem 含 Order 與 Product 導覽屬性
- **WHEN** 開發者讀取 `OrderItem.Order` 或 `OrderItem.Product`
- **THEN** SHALL 回傳對應 Entity（Product 可為 null，商品軟刪除後保留快照）
