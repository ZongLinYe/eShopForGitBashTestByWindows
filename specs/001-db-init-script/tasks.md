# Tasks: 新增資料庫建立腳本

**Input**: Design documents from `/specs/001-db-init-script/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, quickstart.md ✅

**Tests**: 未在規格中要求，無測試任務。
**Organization**: 任務依 User Story 分組，各故事可獨立實作與驗證。

## Format: `[ID] [P?] [Story] Description`

- **[P]**: 可平行執行（不同段落或無相依性）
- **[Story]**: 對應 spec.md 中的 User Story（US1、US2、US3）
- 所有路徑皆為相對於專案根目錄

---

## Phase 1: Setup（建立先決結構）

**目的**: 建立存放腳本所需的資料夾結構

- [X] T001 在專案根目錄建立 `DatabaseScripts/` 資料夾

---

## Phase 2: Foundational（基礎準備，阻斷所有 User Story）

**目的**: 建立腳本骨架並預先取得 PBKDF2 雜湊值，所有 User Story 均依賴此階段完成

**⚠️ 重要**: 此階段未完成前，不得開始任何 User Story 的實作

- [X] T002 建立 `DatabaseScripts/V001_CreateEShopDB.sql` 空白腳本骨架（含標頭說明註解、`USE master` 與 `GO` 批次分隔符佔位）
- [X] T003 以 .NET `Rfc2898DeriveBytes`（SHA256，310,000 次迭代，128-bit salt）預先計算 `admin` 帳號的 `PasswordHash` 與 `PasswordSalt` Base64 值（明文密碼：`Admin@123456`），記錄供 T016 使用

**Checkpoint**: 腳本骨架已建立、PBKDF2 雜湊值已備妥 → 可開始 User Story 實作

---

## Phase 3: User Story 1 - 開發成員首次建立資料庫（Priority: P1）🎯 MVP

**目標**: 實作完整 DDL（7 張資料表 + 外鍵）及所有種子資料（15 筆），讓開發成員能從零建立可運作的 eShopDB

**Independent Test**: 在空白 SQL Server 執行腳本後，以 `quickstart.md` 驗證腳本確認 7 張資料表全數建立、15 筆種子資料正確填入（Categories=4, Products=8, Banners=2, Users=1）

### 資料庫與資料表 DDL（DatabaseScripts/V001_CreateEShopDB.sql）

- [X] T004 [US1] 在 `DatabaseScripts/V001_CreateEShopDB.sql` 中撰寫冪等資料庫建立段落（`IF NOT EXISTS (SELECT name FROM sys.databases ...) BEGIN CREATE DATABASE eShopDB END`，接著 `USE eShopDB`）
- [X] T005 [P] [US1] 撰寫 `Users` 資料表 DDL（12 個欄位：`Id`、`Username`、`Email`、`PasswordHash`、`PasswordSalt`、`Role`、`IsEmailVerified`、`TwoFactorMethod`、`TotpSecret`、`CreatedAt`、`UpdatedAt`、`IsDeleted`），加入 `UQ_Users_Username`、`UQ_Users_Email` 唯一索引，以 `IF NOT EXISTS OBJECT_ID` 守衛 in `DatabaseScripts/V001_CreateEShopDB.sql`
- [X] T006 [P] [US1] 撰寫 `TwoFactorTokens` 資料表 DDL（6 個欄位：`Id`、`UserId`、`Token`、`ExpiresAt`、`IsUsed`、`CreatedAt`），以 `IF NOT EXISTS OBJECT_ID` 守衛 in `DatabaseScripts/V001_CreateEShopDB.sql`
- [X] T007 [P] [US1] 撰寫 `Categories` 資料表 DDL（8 個欄位：`Id`、`Name`、`Slug`、`IconUrl`、`DisplayOrder`、`CreatedAt`、`UpdatedAt`、`IsDeleted`），加入 `UQ_Categories_Slug` 唯一索引，以 `IF NOT EXISTS OBJECT_ID` 守衛 in `DatabaseScripts/V001_CreateEShopDB.sql`
- [X] T008 [P] [US1] 撰寫 `Products` 資料表 DDL（12 個欄位：`Id`、`Name`、`Description`、`Price`、`StockQuantity`、`ImageUrl`、`CategoryId`、`AverageRating`、`ReviewCount`、`CreatedAt`、`UpdatedAt`、`IsDeleted`），以 `IF NOT EXISTS OBJECT_ID` 守衛 in `DatabaseScripts/V001_CreateEShopDB.sql`
- [X] T009 [P] [US1] 撰寫 `Banners` 資料表 DDL（10 個欄位：`Id`、`Title`、`Subtitle`、`ImageUrl`、`ButtonText`、`ButtonUrl`、`DisplayOrder`、`IsActive`、`CreatedAt`、`UpdatedAt`），以 `IF NOT EXISTS OBJECT_ID` 守衛 in `DatabaseScripts/V001_CreateEShopDB.sql`
- [X] T010 [P] [US1] 撰寫 `Orders` 資料表 DDL（11 個欄位：`Id`、`UserId`、`TotalAmount`、`RecipientName`、`RecipientEmail`、`RecipientPhone`、`ShippingAddress`、`Status`、`Note`、`CreatedAt`、`UpdatedAt`），以 `IF NOT EXISTS OBJECT_ID` 守衛 in `DatabaseScripts/V001_CreateEShopDB.sql`
- [X] T011 [P] [US1] 撰寫 `OrderItems` 資料表 DDL（7 個欄位：`Id`、`OrderId`、`ProductId`（允許 NULL）、`ProductName`、`UnitPrice`、`Quantity`、`CreatedAt`），以 `IF NOT EXISTS OBJECT_ID` 守衛 in `DatabaseScripts/V001_CreateEShopDB.sql`
- [X] T012 [US1] 加入所有 5 條外鍵約束（`FK_TwoFactorTokens_Users` CASCADE DELETE、`FK_Products_Categories` RESTRICT、`FK_Orders_Users` RESTRICT、`FK_OrderItems_Orders` CASCADE DELETE、`FK_OrderItems_Products` SET NULL），以 `IF NOT EXISTS OBJECT_ID` 守衛，附加於對應資料表 DDL 段落後 in `DatabaseScripts/V001_CreateEShopDB.sql`

### 種子資料 DML（DatabaseScripts/V001_CreateEShopDB.sql）

- [X] T013 [US1] 填入 4 筆分類種子資料（Fine Jewelry / Beauty / Home Decor / Lifestyle，含 `Slug`、`DisplayOrder`），以 `IF NOT EXISTS (SELECT 1 FROM Categories WHERE Name = ...)` 條件插入 in `DatabaseScripts/V001_CreateEShopDB.sql`
- [X] T014 [P] [US1] 填入 8 筆商品種子資料（各商品含 `Name`、`Price`、`StockQuantity`、`CategoryId` 對應種子分類），以 `IF NOT EXISTS (SELECT 1 FROM Products WHERE Name = ...)` 條件插入 in `DatabaseScripts/V001_CreateEShopDB.sql`
- [X] T015 [P] [US1] 填入 2 筆 Banner 種子資料（Lumina & Bloom / New Arrivals，含 `Subtitle`、`DisplayOrder`、`IsActive = 1`），以 `IF NOT EXISTS (SELECT 1 FROM Banners WHERE Title = ...)` 條件插入 in `DatabaseScripts/V001_CreateEShopDB.sql`
- [X] T016 [US1] 填入 admin 種子帳號（`Username = 'admin'`、`Email = 'admin@eshop.local'`、`Role = 'Admin'`、`IsEmailVerified = 1`，使用 T003 產生的 `PasswordHash` / `PasswordSalt`），以 `IF NOT EXISTS (SELECT 1 FROM Users WHERE Username = 'admin')` 條件插入 in `DatabaseScripts/V001_CreateEShopDB.sql`

**Checkpoint**: 此時腳本應可在空白環境完整執行，`quickstart.md` 三段驗證查詢全數通過 → US1 獨立完成

---

## Phase 4: User Story 2 - QA 與測試環境快速重建（Priority: P2）

**目標**: 確認腳本完整具備冪等性保護（`IF NOT EXISTS` 守衛），可在已初始化環境中重複執行而不產生錯誤或重複資料

**Independent Test**: 在已建立資料庫的環境中，新增或修改測試資料後再次執行腳本，確認：（1）無錯誤訊息、（2）原有資料保持不變、（3）種子資料未重複插入

### Implementation for User Story 2

- [X] T017 [US2] 逐段稽核 `DatabaseScripts/V001_CreateEShopDB.sql`，確認以下項目均有 `IF NOT EXISTS` 守衛：資料庫建立、每張資料表建立（7 段）、每條外鍵建立（5 段）、每批種子資料插入（4 批）；發現缺漏者補上
- [ ] T018 [US2] 在本機 SQL Server 上執行腳本兩次（第二次模擬重建情境），以 `quickstart.md` 驗證查詢確認重複執行後資料表結構正確、種子資料筆數不變（Categories=4, Products=8, Banners=2, Users=1）

**Checkpoint**: 此時腳本可安全重複執行 → US2 獨立完成

---

## Phase 5: User Story 3 - 資料庫版本追蹤（Priority: P3）

**目標**: 確認腳本依版本命名規範存放於正確路徑，並納入專案版本控制，讓新加入成員能直接取得並使用

**Independent Test**: 在版本控制中確認 `DatabaseScripts/V001_CreateEShopDB.sql` 路徑存在、命名格式符合規範（`V{版號}_{說明}.sql`）；新成員 clone 後可直接執行

### Implementation for User Story 3

- [X] T019 [US3] 確認 `DatabaseScripts/V001_CreateEShopDB.sql` 路徑與檔名符合 AGENTS.md 規範（`DatabaseScripts/` 資料夾、`V{版號}_{說明}.sql` 格式），並在腳本頂部加入版本標頭說明（版本號、建立日期、說明、執行方式參考 `quickstart.md`、測試帳號密碼）
- [ ] T020 [US3] 執行 `bash build.sh` 確認 msbuild 建置成功（純腳本提交亦須遵守規範），以 `git add DatabaseScripts/V001_CreateEShopDB.sql` 加入版本控制，並以 commit message `chore: 新增 V001_CreateEShopDB.sql 資料庫腳本` 提交

**Checkpoint**: 腳本已納入版本控制，任何成員 clone 後可立即使用 → US3 獨立完成

---

## Phase 6: Polish & 跨切面關注點

**目的**: 完整驗證與收尾，涵蓋所有 User Story

- [ ] T021 [P] 執行 `quickstart.md` 完整驗證流程（需人工在 SSMS/sqlcmd 執行）（方法 1 SSMS 或方法 2 sqlcmd）並確認三段驗證查詢全部通過
- [X] T022 [P] 檢閱腳本整體可讀性：確認段落之間有適當的分隔說明註解（每張資料表前加 zh-TW 說明，例如 `-- 建立 Users（會員帳號）資料表`）
- [X] T023 確認 `DatabaseScripts/` 資料夾已加入 `eShop.slnx` 或 README 說明，讓開發者能快速找到腳本入口

---

## Dependencies & Execution Order

### Phase 相依關係

- **Setup (Phase 1)**: 無相依 — 立即開始
- **Foundational (Phase 2)**: 依賴 Phase 1 完成 — **阻斷所有 User Story**
- **User Story Phases (Phase 3–5)**: 全部依賴 Phase 2 完成
  - Phase 3 (US1) 優先，因 US2、US3 均依賴 US1 腳本內容
  - Phase 4 (US2) 依賴 Phase 3 完成（需有完整腳本才能稽核冪等性）
  - Phase 5 (US3) 依賴 Phase 3 完成（需有完整腳本才能提交版控）
- **Polish (Phase 6)**: 依賴所有 User Story 完成

### User Story 相依關係

| User Story | 前置條件 | 可並行 |
|-----------|---------|--------|
| US1 (P1) | Phase 2 完成 | 部分任務（T005–T011、T014–T015）可並行起草 |
| US2 (P2) | **US1 完成** | 稽核任務不可並行（需完整腳本） |
| US3 (P3) | **US1 完成** | T019、T020 可與 US2 並行 |

### 單一 User Story 內部順序

```
T003 (PBKDF2 雜湊) → T016 (admin 種子)
T004 (資料庫建立) → T005–T011 (資料表 DDL，可並行) → T012 (外鍵)
T012 (外鍵完成) → T013 (分類種子) → T014–T015 (商品/Banner 種子，可並行) → T016 (admin 種子)
```

---

## Parallel Execution Example: User Story 1

```bash
# 可同步起草的資料表 DDL 段落（無相互依賴，不同資料表區段）：
Task T005: "撰寫 Users 資料表 DDL in DatabaseScripts/V001_CreateEShopDB.sql"
Task T006: "撰寫 TwoFactorTokens 資料表 DDL in DatabaseScripts/V001_CreateEShopDB.sql"
Task T007: "撰寫 Categories 資料表 DDL in DatabaseScripts/V001_CreateEShopDB.sql"
Task T008: "撰寫 Products 資料表 DDL in DatabaseScripts/V001_CreateEShopDB.sql"
Task T009: "撰寫 Banners 資料表 DDL in DatabaseScripts/V001_CreateEShopDB.sql"
Task T010: "撰寫 Orders 資料表 DDL in DatabaseScripts/V001_CreateEShopDB.sql"
Task T011: "撰寫 OrderItems 資料表 DDL in DatabaseScripts/V001_CreateEShopDB.sql"

# T012 須等 T005–T011 全部完成後才可執行（外鍵參照需資料表存在）
```

---

## Implementation Strategy

### MVP First（僅 User Story 1）

1. 完成 Phase 1 Setup
2. 完成 Phase 2 Foundational（**關鍵：取得 PBKDF2 雜湊值**）
3. 完成 Phase 3 User Story 1
4. **停下驗證**：以 `quickstart.md` 確認資料庫結構與種子資料正確 → **MVP 完成**

### Incremental Delivery

1. Phase 1 + Phase 2 完成 → 骨架就緒
2. Phase 3（US1）完成 → 可立即讓所有開發成員初始化資料庫 ✅ **MVP！**
3. Phase 4（US2）完成 → QA 環境可安全重建 ✅
4. Phase 5（US3）完成 → 腳本納入版本控制，新成員可直接取用 ✅
5. Phase 6（Polish）完成 → 全功能交付 ✅

---

## Summary

| 項目 | 數量 |
|------|------|
| 總任務數 | 23 |
| Phase 1 (Setup) | 1 |
| Phase 2 (Foundational) | 2 |
| Phase 3 (US1 P1) | 13 |
| Phase 4 (US2 P2) | 2 |
| Phase 5 (US3 P3) | 2 |
| Phase 6 (Polish) | 3 |
| **可並行任務 [P]** | **9** |
| **US1 任務** | **13** |
| **US2 任務** | **2** |
| **US3 任務** | **2** |

**建議 MVP 範圍**: Phase 1 + Phase 2 + Phase 3（US1）→ 13 個任務即可交付核心價值
