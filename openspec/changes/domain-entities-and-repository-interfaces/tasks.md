## 1. eShop.Domain — Entity 類別

- [ ] 1.1 建立 `eShop.Domain/Entities/User.cs`：對應 `dbo.Users`，含所有欄位屬性與 `virtual ICollection<Order> Orders`、`virtual ICollection<TwoFactorToken> TwoFactorTokens` 導覽屬性，XML 文件完整
- [ ] 1.2 建立 `eShop.Domain/Entities/TwoFactorToken.cs`：對應 `dbo.TwoFactorTokens`，含外鍵 `UserId` 與 `virtual User User` 導覽屬性，XML 文件完整
- [ ] 1.3 建立 `eShop.Domain/Entities/Category.cs`：對應 `dbo.Categories`，含 `IsDeleted` 欄位與 `virtual ICollection<Product> Products` 導覽屬性，XML 文件完整
- [ ] 1.4 建立 `eShop.Domain/Entities/Product.cs`：對應 `dbo.Products`，含 `CategoryId`、`IsDeleted` 欄位與 `virtual Category Category` 導覽屬性，XML 文件完整
- [ ] 1.5 建立 `eShop.Domain/Entities/Banner.cs`：對應 `dbo.Banners`（無 `IsDeleted`，以 `IsActive` 控制），XML 文件完整
- [ ] 1.6 建立 `eShop.Domain/Entities/Order.cs`：對應 `dbo.Orders`，`Status` 屬性型別為 `OrderStatus` enum，含 `virtual User User`、`virtual ICollection<OrderItem> OrderItems` 導覽屬性，XML 文件完整
- [ ] 1.7 建立 `eShop.Domain/Entities/OrderItem.cs`：對應 `dbo.OrderItems`，`ProductId` 允許 null，含 `virtual Order Order`、`virtual Product Product` 導覽屬性，XML 文件完整

## 2. eShop.Domain — Repository 介面

- [ ] 2.1 建立 `eShop.Domain/Interfaces/Repositories/IRepository.cs`：泛型基底介面，定義 `T GetById(int id)`、`void Add(T entity)`、`void Update(T entity)`，XML 文件完整
- [ ] 2.2 建立 `eShop.Domain/Interfaces/Repositories/IUserRepository.cs`：繼承 `IRepository<User>`，補充 `GetByUsername`、`GetByEmail`、`SoftDelete`，XML 文件完整
- [ ] 2.3 建立 `eShop.Domain/Interfaces/Repositories/ICategoryRepository.cs`：繼承 `IRepository<Category>`，補充 `GetAll`、`GetBySlug`，XML 文件完整
- [ ] 2.4 建立 `eShop.Domain/Interfaces/Repositories/IProductRepository.cs`：繼承 `IRepository<Product>`，補充 `GetByCategory`、`GetBestSellers`、`Search`、`CountByCategory`、`CountByKeyword`，XML 文件完整
- [ ] 2.5 建立 `eShop.Domain/Interfaces/Repositories/IBannerRepository.cs`：繼承 `IRepository<Banner>`，補充 `GetActiveOrdered`，XML 文件完整
- [ ] 2.6 建立 `eShop.Domain/Interfaces/Repositories/IOrderRepository.cs`：繼承 `IRepository<Order>`，補充 `GetByUserId`、`GetByIdWithItems`、`UpdateStatus`，XML 文件完整

## 3. eShop.Domain.csproj — 更新編譯條目

- [ ] 3.1 在 `eShop.Domain.csproj` 的 `<ItemGroup>` 中加入 7 個 Entity 的 `<Compile Include="Entities\*.cs" />` 條目（或逐一列出每個檔案路徑）
- [ ] 3.2 在 `eShop.Domain.csproj` 中加入 6 個 Repository 介面的 `<Compile Include="Interfaces\Repositories\*.cs" />` 條目（含 `IRepository.cs`）

## 4. eShop.Repositories — DbContext

- [ ] 4.1 建立 `eShop.Repositories/Data/EShopDbContext.cs`：繼承 `DbContext`，建構子接受連線字串名稱 `"eShopDB"`，宣告 7 個 `DbSet<T>`，`OnModelCreating` 設定所有表名映射（`ToTable("Users")` 等），XML 文件完整

## 5. eShop.Repositories — Repository 實作

- [ ] 5.1 建立 `eShop.Repositories/Repositories/UserRepository.cs`：實作 `IUserRepository`，注入 `EShopDbContext`，所有查詢加 `.Where(x => !x.IsDeleted)`，XML 文件完整
- [ ] 5.2 建立 `eShop.Repositories/Repositories/CategoryRepository.cs`：實作 `ICategoryRepository`，`GetAll` 加 `.Where(x => !x.IsDeleted).OrderBy(x => x.DisplayOrder)`，XML 文件完整
- [ ] 5.3 建立 `eShop.Repositories/Repositories/ProductRepository.cs`：實作 `IProductRepository`，分頁查詢加 `.Where(x => !x.IsDeleted)`，`GetBestSellers` 依 `AverageRating` 降冪，XML 文件完整
- [ ] 5.4 建立 `eShop.Repositories/Repositories/BannerRepository.cs`：實作 `IBannerRepository`，`GetActiveOrdered` 篩選 `IsActive = true` 並依 `DisplayOrder` 排序，XML 文件完整
- [ ] 5.5 建立 `eShop.Repositories/Repositories/OrderRepository.cs`：實作 `IOrderRepository`，`GetByIdWithItems` 使用 `.Include(o => o.OrderItems)` 明確載入，`GetByUserId` 依 `CreatedAt` 降冪分頁，XML 文件完整

## 6. eShop.Repositories.csproj — 更新編譯條目

- [ ] 6.1 在 `eShop.Repositories.csproj` 的 `<ItemGroup>` 中加入 `EShopDbContext.cs` 的 `<Compile Include="Data\EShopDbContext.cs" />` 條目
- [ ] 6.2 在 `eShop.Repositories.csproj` 中加入 5 個 Repository 實作的 `<Compile Include="Repositories\*.cs" />` 條目（或逐一列出）

## 7. 驗證

- [ ] 7.1 執行 `bash build.sh` 確認 0 個錯誤
- [ ] 7.2 確認所有新增 `.cs` 檔案皆在對應 `.csproj` 中有 `<Compile>` 條目（用 `grep -r "Compile Include" eShop.Domain/eShop.Domain.csproj` 確認）
- [ ] 7.3 確認 `Class1.cs` 已從 `eShop.Domain` 與 `eShop.Repositories` 中移除（或清空），不留死碼
