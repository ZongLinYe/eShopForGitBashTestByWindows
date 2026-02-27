## Why

目前 `eShop.Domain` 與 `eShop.Repositories` 專案僅有空殼 `Class1.cs`，缺乏 Entity 類別、Repository 介面與 DbContext，無法進行任何資料存取操作。資料庫腳本（V001）已就緒，現在需要建立對應的程式碼層，才能讓後續的 Service 層與 Controller 正常運作。

## What Changes

- 在 `eShop.Domain/Entities/` 新增 7 個 Entity 類別（`User`、`TwoFactorToken`、`Category`、`Product`、`Banner`、`Order`、`OrderItem`）
- 在 `eShop.Domain/Interfaces/Repositories/` 新增泛型基底介面 `IRepository<T>` 與 5 個具體 Repository 介面（`IUserRepository`、`ICategoryRepository`、`IProductRepository`、`IBannerRepository`、`IOrderRepository`）
- 在 `eShop.Repositories/Data/` 新增 `EShopDbContext`，繼承 `DbContext`，宣告所有 `DbSet<T>` 並設定表名映射
- 在 `eShop.Repositories/Repositories/` 新增 5 個 Repository 實作類別
- 更新 `eShop.Domain.csproj` 與 `eShop.Repositories.csproj`，加入所有新增檔案的 `<Compile Include="..." />` 條目

## Capabilities

### New Capabilities

- `domain-entities`: 7 個 Entity 類別，屬性與資料表欄位完全對應，含 `virtual` 導覽屬性支援 EF6 Lazy Loading
- `repository-interfaces`: 泛型基底介面 `IRepository<T>` 與 5 個具體 Repository 介面，定義資料存取契約
- `ef6-dbcontext`: `EShopDbContext` 設定所有 `DbSet<T>` 與表名映射
- `repository-implementations`: 5 個 Repository 實作，含軟刪除過濾（`.Where(x => !x.IsDeleted)`）與明確 `.Include()` 載入

### Modified Capabilities

（無，本次為全新建立）

## Impact

- **eShop.Domain.csproj**：新增 `Entities/` 與 `Interfaces/Repositories/` 資料夾下共 13 個 `.cs` 檔案的編譯條目
- **eShop.Repositories.csproj**：新增 `Data/` 與 `Repositories/` 資料夾下共 6 個 `.cs` 檔案的編譯條目
- **後續 Commit 4+**：所有 Service 層皆依賴本次建立的 Repository 介面，AutofacConfig 需在 Commit 3 完成後才能完整註冊
- **無 Breaking Change**：目前系統尚無任何對 Domain / Repositories 的呼叫端
