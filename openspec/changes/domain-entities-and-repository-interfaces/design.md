## Context

資料庫（eShopDB）已由 `V001_CreateEShopDB.sql` 建立完成，共 7 張資料表（Users、TwoFactorToken、Categories、Products、Banners、Orders、OrderItems）。目前 `eShop.Domain` 與 `eShop.Repositories` 專案中只有空殼 `Class1.cs`，無任何可用的程式碼結構。

本次採用「Code First on Existing DB」方式：手寫 Entity 類別與 DbContext，屬性名稱與資料表欄位完全對應，**不使用** EF Migration 或 EDMX 反向工程。

**約束條件**：
- .NET Framework 4.6.2，Entity Framework 6
- `.csproj` 需手動維護每個 `<Compile Include="..." />`
- 每個 `.cs` 檔案只含一個型別（класс/介面）

## Goals / Non-Goals

**Goals:**
- 建立 7 個 Entity 類別，完整對應資料表結構與導覽屬性
- 建立 `IRepository<T>` 泛型基底介面與 5 個具體 Repository 介面
- 建立 `EShopDbContext` 配置所有 DbSet 與表名映射
- 建立 5 個 Repository 實作，含軟刪除過濾與明確 `.Include()` 載入
- 更新兩個 `.csproj` 加入所有新增檔案的 Compile 條目

**Non-Goals:**
- 不實作 Service 層（Commit 5+）
- 不設定 Autofac DI 註冊（Commit 1 的 AutofacConfig 已有框架）
- 不做 EF Migration 或資料庫結構異動
- 不加入 Unit Test（MVP 原則，後續迭代）

## Decisions

### D1：採用 Code First on Existing DB，手寫 Entity + DbContext

**決策**：手寫所有 Entity 類別，不使用 EF6 EDMX 反向工程或 `.tt` 模板自動產生。

**理由**：反向工程自動產生的程式碼難以加入 XML 文件、命名慣例不符合本專案規範；手寫可完全掌控。

**替代方案**：EF6 Database First (EDMX) → 產生的部分類別難以維護，且 EDMX 設計器在 VS Code 中不支援。

---

### D2：Repository 層手動加 `.Where(x => !x.IsDeleted)` 而非 EF6 攔截器

**決策**：每個 Repository 查詢方法明確加上 `.Where(x => !x.IsDeleted)` 軟刪除過濾。

**理由**：EF6 攔截器實作複雜（需操作 SQL 字串）、容易誤傷 JOIN、難以 debug；明確過濾則清晰可見、可測試。

**替代方案**：`IDbCommandInterceptor` 全域注入 WHERE 條件 → 過於複雜，違反 MVP 原則與 KISS 原則。

---

### D3：建立 `IRepository<T>` 泛型基底介面

**決策**：在 `eShop.Domain/Interfaces/Repositories/IRepository.cs` 定義 `T GetById(int id)`、`void Add(T entity)`、`void Update(T entity)` 三個通用方法；各具體介面繼承並補充自訂查詢方法。

**理由**：DRY 原則，避免 5 個介面各自重複定義相同方法；同時保持介面隔離（ISP），自訂方法放個別介面。

**替代方案**：各介面完全獨立不繼承 → 違反 DRY，CRUD 方法重複 5 次。

---

### D4：Entity 允許 `virtual` 導覽屬性，載入由 Repository 以 `.Include()` 控制

**決策**：Entity 加入 `virtual` 導覽屬性支援 EF6 Lazy Loading，但 Repository 外部嚴禁觸發 Lazy Load；Repository 方法若需關聯資料必須明確 `.Include()`。

**理由**：導覽屬性提升查詢可讀性；但不受控的 Lazy Load 在迴圈中會造成 N+1 查詢。透過程式碼規範與 XML 文件警告強制約束。

**替代方案**：完全不加導覽屬性 → 所有關聯查詢需手動 JOIN，增加 Repository 複雜度且降低可讀性。

## Risks / Trade-offs

- **N+1 查詢風險**：若開發者在 Repository 以外直接讀取導覽屬性，EF6 會對每筆記錄各發一次 SQL → 緩解：XML `<remarks>` 文件加入警告，AGENTS.md 已明確禁止。
- **.csproj 手動維護風險**：新增 `.cs` 檔未加入 `.csproj` 會導致 msbuild 靜默略過編譯 → 緩解：`plan-eShopFullFeatures.prompt.md` 的 Commit 3 已加入明確提醒，每次 commit 前須執行 `bash build.sh`。
- **欄位名稱對齊風險**：Entity 屬性名稱若與資料表欄位不一致，EF6 查詢會失敗 → 緩解：規範要求名稱完全一致，必要時以 `[Column("")]` 明確映射。
- `Banners` 表無 `IsDeleted` 欄位，軟刪除規則不適用 → 緩解：`BannerRepository` 改以 `IsActive` 作為篩選條件，不使用通用軟刪除介面。
