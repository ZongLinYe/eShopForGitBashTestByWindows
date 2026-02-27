# Feature Specification: 新增資料庫建立腳本

**Feature Branch**: `001-db-init-script`
**Created**: 2026-02-27
**Status**: Draft
**Input**: User description: "新增資料庫建立腳本"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 開發成員首次建立資料庫 (Priority: P1)

開發成員或新加入專案的成員，需要能夠透過一份腳本，從零開始建立完整的 eShop 資料庫，包含所有資料表與初始種子資料，讓本機開發環境能立即運作。

**Why this priority**: 這是整個系統的資料基礎。沒有正確初始化的資料庫，所有功能均無法執行。此故事是後續所有開發工作的先決條件。

**Independent Test**: 在一個全新且空白的資料庫伺服器上執行腳本後，確認所有資料表存在、關聯正確，且種子資料已填入，即可獨立驗證此故事的價值。

**Acceptance Scenarios**:

1. **Given** 資料庫伺服器上不存在 `eShopDB` 資料庫，**When** 執行建立腳本，**Then** `eShopDB` 資料庫被建立，且包含所有 7 張資料表（`Users`、`TwoFactorTokens`、`Categories`、`Products`、`Banners`、`Orders`、`OrderItems`）。
2. **Given** 腳本執行完成後，**When** 查詢各資料表，**Then** 每張表的欄位定義、資料型別、主鍵、外鍵關聯均符合規格，且種子資料（4 個分類、8 個商品、2 個 Banner、1 個測試管理員帳號）已正確填入。
3. **Given** 種子測試帳號已建立，**When** 使用該帳號嘗試登入系統，**Then** 應能成功通過身份驗證，且帳號角色為管理員（`Admin`）。

---

### User Story 2 - QA 與測試環境快速重建 (Priority: P2)

QA 工程師或開發人員需要能夠在測試環境中快速重建資料庫，以確保測試資料的一致性，並能針對乾淨的資料庫狀態執行測試。

**Why this priority**: 可重複執行的資料庫初始化腳本能確保測試環境的一致性，減少「只在我的電腦能跑」的問題，提升測試可靠性。

**Independent Test**: 先在測試環境建立資料庫，人為新增或修改資料後，再次執行腳本（重建），確認資料庫回到初始種子狀態，即可獨立驗證。

**Acceptance Scenarios**:

1. **Given** 測試環境資料庫存在且含有測試資料，**When** 重新執行建立腳本，**Then** 資料庫回復至標準種子資料狀態，無殘餘測試資料。
2. **Given** 多位開發人員各自執行腳本，**When** 比較各自資料庫的結構與種子資料，**Then** 所有環境的資料表結構與初始資料完全一致。

---

### User Story 3 - 資料庫版本追蹤 (Priority: P3)

團隊需要能追蹤資料庫結構的版本演進，確保每次資料庫變更都有對應腳本記錄，便於稽核與回溯。

**Why this priority**: 版本命名規範（如 `V001_`）建立了良好的基礎習慣，讓未來的資料庫升級腳本能有序管理，降低維護成本。

**Independent Test**: 確認腳本存放於 `DatabaseScripts/` 資料夾下、以 `V001_` 命名，且日後新增 `V002_` 腳本時能明確識別執行順序。

**Acceptance Scenarios**:

1. **Given** 專案版本控制中，**When** 查看 `DatabaseScripts/` 資料夾，**Then** 存在命名為 `V001_CreateEShopDB.sql` 的腳本，命名格式符合版本管理規範。
2. **Given** 腳本已納入版本控制，**When** 新成員 clone 專案，**Then** 可在 `DatabaseScripts/` 資料夾中找到腳本，並能依此自行完成資料庫初始化。

---

### Edge Cases

- 若 `eShopDB` 資料庫已存在時再次執行腳本，系統應安全處理（不重複建立、不拋出破壞性錯誤）？
- 若腳本執行途中因連線中斷或權限不足而失敗，資料庫應保持一致性狀態（不殘留部分建立的資料表）？
- 種子測試帳號的預設密碼是否需要隨附文件說明，以便開發人員知道如何登入測試？

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 腳本 MUST 在空白資料庫伺服器上執行後，建立名為 `eShopDB` 的資料庫及完整的 7 張資料表。
- **FR-002**: 每張資料表 MUST 包含 `CreatedAt`（建立時間）欄位；`Users`、`Categories`、`Products` 三張表 MUST 另包含 `UpdatedAt`（最後更新時間）欄位。
- **FR-003**: `Users`、`Categories`、`Products` 資料表 MUST 包含 `IsDeleted` 欄位，支援軟刪除（邏輯刪除）而非實際移除資料列。
- **FR-004**: 腳本執行後 MUST 自動填入種子資料：4 個商品分類、8 個商品（含售價、庫存、所屬分類）、2 個首頁 Banner、1 個具有管理員角色的測試帳號。
- **FR-005**: `TwoFactorTokens` 資料表 MUST 關聯至 `Users` 資料表，並包含有效期限（`ExpiresAt`）與已使用狀態（`IsUsed`）欄位。
- **FR-006**: `OrderItems` 資料表 MUST 記錄下單當下的商品名稱與單價快照（不依賴商品現有資料），確保歷史訂單資料不受商品異動影響。
- **FR-007**: 腳本 MUST 放置於專案的 `DatabaseScripts/` 資料夾，檔案命名遵循 `V{版號}_{說明}.sql` 格式。

### Key Entities

- **Users（會員帳號）**: 儲存會員與管理員的帳號資訊，包含身份識別、密碼安全儲存、Email 驗證狀態、雙因素驗證方式設定（Email OTP 或 TOTP）、角色權限（Member / VipMember / Admin / SuperAdmin）。
- **TwoFactorTokens（雙因素驗證碼）**: 儲存臨時性的一次性驗證碼，紀錄對應的會員、到期時間、以及是否已被使用，用於登入第二步驗證流程。
- **Categories（商品分類）**: 儲存商品分類資訊，包含分類名稱、識別別名（用於 URL）、圖示連結、顯示排序，支援軟刪除。
- **Products（商品）**: 儲存商品目錄資訊，包含名稱、描述、售價、庫存數量、商品圖片、所屬分類、平均評分與評論數量，支援軟刪除。
- **Banners（首頁輪播廣告）**: 儲存首頁廣告橫幅資訊，包含標題、副標題、圖片連結、按鈕文字與連結、顯示排序、是否啟用。
- **Orders（訂單）**: 儲存整筆訂單資訊，包含下單會員、訂單總金額、收件人姓名／Email／電話、收件地址、訂單狀態（Pending / Confirmed / Shipped / Delivered / Cancelled）、備註。
- **OrderItems（訂單明細）**: 儲存訂單內每項商品的明細，包含所屬訂單、商品參考、下單當下的商品名稱快照、單價快照、購買數量。

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 開發成員在取得腳本後，可在 5 分鐘內完成本機資料庫初始化，無需手動建立任何資料表或手動輸入初始資料。
- **SC-002**: 腳本執行完成後，7 張資料表全數建立，種子資料 15 筆（4 分類 + 8 商品 + 2 Banner + 1 管理員帳號）全數正確填入，錯誤率為 0。
- **SC-003**: 所有外鍵關聯（`TwoFactorTokens → Users`、`Products → Categories`、`Orders → Users`、`OrderItems → Orders`、`OrderItems → Products`）均正確建立，資料完整性約束生效。
- **SC-004**: 腳本可在不同開發人員環境中重複執行，每次執行後的資料表結構與種子資料完全一致，不因執行者或執行次數不同而產生差異。

## Assumptions

- 目標資料庫伺服器為 SQL Server（本機或區域網路），執行腳本的帳號具備建立資料庫的權限。
- 種子測試管理員帳號的密碼將以與應用程式相同的雜湊方式儲存（非明文），確保帳號可直接透過系統登入介面驗證使用。
- 腳本採冪等性設計（Idempotent），即腳本可重複執行而不產生錯誤（已存在的資料庫或資料表不重複建立）。
- 種子商品需分屬 4 個預設分類（例如：Fine Jewelry、Beauty、Home Decor、Lifestyle），確保前端分類篩選功能可立即測試。
