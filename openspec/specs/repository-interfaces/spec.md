## ADDED Requirements

### Requirement: IRepository 泛型基底介面
系統 SHALL 在 `eShop.Domain/Interfaces/Repositories/` 定義 `IRepository<T>` 泛型介面，提供 CRUD 基本操作契約。

#### Scenario: IRepository 包含三個通用方法
- **WHEN** 開發者參照 `IRepository<T>`
- **THEN** SHALL 包含 `T GetById(int id)`、`void Add(T entity)`、`void Update(T entity)` 三個方法簽章

---

### Requirement: IUserRepository 介面
系統 SHALL 定義 `IUserRepository`，繼承 `IRepository<User>` 並補充使用者查詢方法。

#### Scenario: IUserRepository 包含專屬查詢方法
- **WHEN** 開發者參照 `IUserRepository`
- **THEN** SHALL 包含 `User GetByUsername(string username)`、`User GetByEmail(string email)` 方法

#### Scenario: IUserRepository 含軟刪除操作
- **WHEN** 開發者呼叫 `IUserRepository`
- **THEN** SHALL 包含 `void SoftDelete(int id)` 方法

---

### Requirement: ICategoryRepository 介面
系統 SHALL 定義 `ICategoryRepository`，繼承 `IRepository<Category>` 並補充分類查詢方法。

#### Scenario: ICategoryRepository 包含全部取得與 Slug 查詢
- **WHEN** 開發者參照 `ICategoryRepository`
- **THEN** SHALL 包含 `IList<Category> GetAll()` 與 `Category GetBySlug(string slug)` 方法

---

### Requirement: IProductRepository 介面
系統 SHALL 定義 `IProductRepository`，繼承 `IRepository<Product>` 並補充商品查詢方法。

#### Scenario: IProductRepository 包含分頁與分類查詢
- **WHEN** 開發者參照 `IProductRepository`
- **THEN** SHALL 包含 `IList<Product> GetByCategory(int categoryId, int page, int pageSize)` 方法

#### Scenario: IProductRepository 包含暢銷商品與關鍵字查詢
- **WHEN** 開發者參照 `IProductRepository`
- **THEN** SHALL 包含 `IList<Product> GetBestSellers(int count)` 與 `IList<Product> Search(string keyword, int page, int pageSize)` 方法

#### Scenario: IProductRepository 含商品總數查詢
- **WHEN** 開發者參照 `IProductRepository`
- **THEN** SHALL 包含 `int CountByCategory(int categoryId)` 與 `int CountByKeyword(string keyword)` 方法（分頁時計算總筆數用）

---

### Requirement: IBannerRepository 介面
系統 SHALL 定義 `IBannerRepository`，繼承 `IRepository<Banner>` 並補充啟用 Banner 查詢方法。

#### Scenario: IBannerRepository 包含取得啟用 Banner 方法
- **WHEN** 開發者參照 `IBannerRepository`
- **THEN** SHALL 包含 `IList<Banner> GetActiveOrdered()` 方法，依 `DisplayOrder` 排序

---

### Requirement: IOrderRepository 介面
系統 SHALL 定義 `IOrderRepository`，繼承 `IRepository<Order>` 並補充訂單查詢方法。

#### Scenario: IOrderRepository 包含依使用者查詢訂單
- **WHEN** 開發者參照 `IOrderRepository`
- **THEN** SHALL 包含 `IList<Order> GetByUserId(int userId, int page, int pageSize)` 方法

#### Scenario: IOrderRepository 包含訂單詳情查詢（含明細）
- **WHEN** 開發者參照 `IOrderRepository`
- **THEN** SHALL 包含 `Order GetByIdWithItems(int orderId)` 方法（以 `.Include()` 載入 OrderItems）

#### Scenario: IOrderRepository 含更新訂單狀態方法
- **WHEN** 開發者參照 `IOrderRepository`
- **THEN** SHALL 包含 `void UpdateStatus(int orderId, OrderStatus status)` 方法
