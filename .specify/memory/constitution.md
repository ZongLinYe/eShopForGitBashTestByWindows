<!--
SYNC IMPACT REPORT
==================
Version Change: [PLACEHOLDER template] → 1.0.0
Bump Type: MAJOR（從空白範本首次批准，全新原則定義）

Added Principles:
  - I. 程式碼品質（Code Quality）
  - II. 測試標準（Testing Standards）
  - III. 使用者體驗一致性（UX Consistency）
  - IV. 效能要求（Performance Requirements）
  - V. 文件語言規範（Documentation Language）

Added Sections:
  - 安全性與架構分層約束
  - 開發流程品質關卡

Removed Sections: 無（首次建立）

Templates Status:
  ✅ .specify/templates/plan-template.md  — Constitution Check gate 已對應所有 5 項原則
  ✅ .specify/templates/spec-template.md  — User Stories 需求完整性與中文文件規範對齊
  ✅ .specify/templates/tasks-template.md — 任務分類與品質關卡欄位已對應

Follow-up TODOs:
  - 未來新增效能測試工具時，請更新「IV. 效能要求」中的具體測量工具與基準值
  - CONSTITUTION_VERSION 應隨每次修訂自動遞增，並更新 LAST_AMENDED_DATE
-->

# eShop Constitution

## Core Principles

### I. 程式碼品質（Code Quality）

eShop 的每一行程式碼 MUST 遵守以下不可妥協的品質原則：

**SOLID 設計原則**
- 每個類別 MUST 只負責單一職責（SRP），變更原因唯一。
- 新增功能 MUST 透過新增類別或實作介面完成，禁止修改已穩定的既有類別（OCP）。
- 介面實作 MUST 完整遵守介面契約，子類別可替換父類別且不破壞正確性（LSP）。
- 介面 MUST 細分拆離，禁止強迫實作類別依賴不需要的方法（ISP）。
- Controller MUST 依賴介面（如 `IProductService`）而非具體實作（DIP），透過 Autofac 注入。

**Clean Code 規範**
- 命名 MUST 自我說明，禁止使用 `d`、`temp`、`DoStuff()` 等不具意義的名稱。
- 方法行數 SHOULD 控制在 20 行以內；超過則 MUST 拆分。
- 數字與字串常數 MUST 抽取為具名常數，禁止魔法數字。
- 已廢棄的程式碼 MUST 刪除，禁止以註解形式保留在檔案中。
- `catch` 區塊 MUST 有意義的錯誤處理，禁止空 `catch` 吞掉例外。
- 每個 `.cs` 檔案 MUST 只包含一個型別定義（class / enum / struct / interface）。
- 所有 class / interface / method / property MUST 有 XML 文件註解（`<summary>`）。
- 行內註解（inline comment）MUST 使用 zh-TW 繁體中文。

**DRY / KISS / YAGNI**
- 重複邏輯 MUST 抽取為共用方法，禁止跨層複製相同查詢或驗證邏輯。
- 實作 MUST 選擇最簡單可行方案，優先直觀勝過聰明。
- 未有明確需求的功能 MUST NOT 預先實作；禁止建立無使用者的抽象層。

---

### II. 測試標準（Testing Standards）

**建置閘門（BUILD GATE）**
- 每次 `git commit` 前 MUST 執行 `bash build.sh`，確認 msbuild 建置成功（0 個錯誤）。
- 建置失敗的程式碼 MUST NOT 進入版本控制。
- 建置指令：`bash build.sh`（Debug）或 `bash build.sh Release`。

**功能驗證（FUNCTIONAL GATE）**
- 每個新功能完成後 MUST 可實際執行並手動驗證主要流程（Happy Path）。
- 資料庫腳本 MUST 在 SQL Server 上執行無誤後才可 commit。
- API 端點與 Controller Action MUST 在 IIS Express 或本機伺服器上完成瀏覽器驗證。

**半成品禁令**
- 未完成的功能 MUST NOT commit；功能 MUST 達到「可實際執行與驗證」的完整狀態。

---

### III. 使用者體驗一致性（UX Consistency）

**設計語言（Lumina & Bloom）**
- 全站視覺 MUST 遵循 Lumina & Bloom 設計語言：玫瑰粉 `#C8957A`、奶油桃 `#B8956A`、乳白底 `#FAF7F4`、深棕文字 `#3C3028` 四色系。
- 禁止使用純黑（`#000000`）或純白（`#FFFFFF`）作為頁面背景或主文字色。
- 商品卡、表單、按鈕 MUST 遵循 Site.css 統一定義的元件樣式，禁止頁面內自訂覆蓋。

**前端技術約束**
- 禁止使用 jQuery，所有互動 MUST 使用 VanillaJS。
- 禁止使用 `innerHTML`，DOM 操作 MUST 使用 `textContent` 或 `createElement`/`appendChild`。
- AJAX 請求 MUST 使用原生 `fetch` API，回傳格式統一為 JSON。

**RWD 斷點**
- 所有頁面 MUST 支援三個斷點：桌面（≥1024px）、平板（768–1023px）、手機（<768px）。
- 手機版 MUST 可正常操作核心流程（商品瀏覽、加入購物車、結帳）。

**表單與驗證**
- 表單驗證 MUST 統一使用 FluentValidation（`eShop.Services` 層），ViewModel MUST NOT 使用 DataAnnotations。
- 所有 POST 表單 MUST 有 `@Html.AntiForgeryToken()` 與 `[ValidateAntiForgeryToken]`。
- 驗證錯誤訊息 MUST 以 zh-TW 呈現，在 View 的對應欄位旁顯示。

---

### IV. 效能要求（Performance Requirements）

**頁面回應時間**
- 頁面初次載入 SHOULD 在本機開發環境（SQL Server 本機）完成於 2 秒以內。
- 列表頁（商品列表、訂單列表）MUST 實作分頁（預設每頁 ≤ 20 筆），禁止一次載入全部資料。

**資料庫查詢**
- Repository 層 MUST NOT 產生 N+1 查詢問題；關聯資料 MUST 透過 `Include()` 或明確 JOIN 一次載入。
- 頻繁查詢的欄位（如 `Products.CategoryId`、`Products.IsDeleted`）MUST 在資料庫層建立索引。
- 所有軟刪除查詢 MUST 包含 `WHERE IsDeleted = 0` 條件，避免載入已刪除資料。

**資源限制**
- Session 購物車資料量 SHOULD 限制於單次操作最多 50 項商品。

---

### V. 文件語言規範（Documentation Language）

**適用範圍：一切由 SpecKit、OpenSpec 或代理人（Agent）產生的文件**，包含但不限於：spec、plan、research、data-model、quickstart、checklist、tasks、constitution。

- 所有文件 MUST 使用 zh-TW 台灣正體中文撰寫，確保甲方、SA、PM、PG 均能直接閱讀與理解業務需求。
- 技術術語若無對應慣用中文譯名（如 Repository、ViewModel、Entity、Slug），可保留英文原文，但 MUST 在首次出現時以中文補充說明。
- 禁止使用中國大陸用語，強制替換規則：
  - 「组件」→「元件」
  - 「获取」→「取得」
  - 「实现」→「實作」
  - 「接口」→「介面」
  - 「数据库」→「資料庫」
  - 「软件」→「軟體」
  - 「框架」維持不變（兩岸相同）
- Commit message MUST 使用中文，格式為 `類型: 簡短說明`（如 `feat: 新增商品列表頁面`）。

---

## 安全性與架構分層約束

eShop 採用嚴格的 5 層分層架構（eShopWeb → Services → Repositories → Domain ← Utility），各層職責不可越界：

| 層 | MUST 做 | MUST NOT 做 |
|----|---------|------------|
| eShopWeb | HTTP 請求/回應、ViewModel 組裝、ModelState | 直接存取 Repository 或 DbContext |
| eShop.Services | 商業規則、FluentValidation、協調 Repository | 直接參考 HttpContext |
| eShop.Repositories | EF6 CRUD、Database First | 包含商業邏輯 |
| eShop.Domain | Entity、Enum、共用介面 | 參考其他專案層 |
| eShop.Utility | Serilog 封裝、通用輔助方法 | 參考 Services / Repositories |

**安全性強制規則**
- 需登入的 Action MUST 加上 `[Authorize]`。
- 禁止在 View 中使用 `@Html.Raw()`，所有輸出 MUST 透過 Razor 預設 HTML 編碼。
- 軟刪除 MUST 使用 `IsDeleted` 旗標，禁止直接 `DELETE` 資料列。

**Service 回傳值**
- Service 方法 MUST 回傳 `ServiceResult` 或 `ServiceResult<T>`，不得直接拋出例外至展示層。
- Controller MUST 依據 `IsSuccess` 決定回應，不直接 catch Service 的例外。

**資料庫版本管理**
- 所有資料庫變更 MUST 提供 T-SQL 腳本放於 `DatabaseScripts/`，命名格式 `V{版號}_{說明}.sql`。
- 建置工具 MUST 使用 `msbuild`，禁止使用 `dotnet` CLI。

---

## 開發流程品質關卡

每個功能從需求到 commit 的完整流程：

```
需求 → /speckit.specify → /speckit.plan → /speckit.tasks → 實作 → msbuild ✅ → 功能驗證 ✅ → git commit
```

**品質關卡清單**（每次 commit 前 MUST 全部通過）：
1. `bash build.sh` 回報 0 個錯誤。
2. 功能主要流程（Happy Path）可在本機瀏覽器手動驗證。
3. 新增的資料庫變更已有對應 T-SQL 腳本。
4. 每個 `.cs` 檔案只含一個型別定義。
5. 所有公開 API（class / method / property）有 XML 文件註解。
6. commit message 使用中文，格式正確。
7. `git add` 只包含本次功能相關的檔案。

**禁止事項**
- 禁止在建置失敗狀態下 commit。
- 禁止使用 `git add .` 一次加入所有檔案。
- 禁止讓半成品進入版本控制。
- 禁止單一 commit 夾帶多個功能。

---

## Governance

本 Constitution 是 eShop 專案的最高開發規範。

- **優先序**：本 Constitution 優先於個人習慣；AGENTS.md 提供本 Constitution 的細節補充；兩者衝突時以本 Constitution 為準。
- **修訂程序**：任何原則變更 MUST 更新本文件版本號、`LAST_AMENDED_DATE`，並在 Sync Impact Report 中說明本次修訂的範圍與理由。
- **版本規則**：MAJOR 為原則移除或不相容重定義；MINOR 為新增原則或章節；PATCH 為措辭澄清或錯字修正。
- **合規驗證**：每次 `/speckit.plan` 執行時的 Constitution Check gate MUST 逐項驗證本 Constitution 所有原則。
- **運行時指引**：日常開發細節參閱 `AGENTS.md`；SpecKit 操作流程參閱 `.github/prompts/` 下的 slash command 文件。

**Version**: 1.0.0 | **Ratified**: 2026-02-27 | **Last Amended**: 2026-02-27
