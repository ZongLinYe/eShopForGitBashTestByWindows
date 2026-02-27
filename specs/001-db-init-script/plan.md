# Implementation Plan: 新增資料庫建立腳本

**Branch**: `001-db-init-script` | **Date**: 2026-02-27 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-db-init-script/spec.md`

## Summary

建立 `DatabaseScripts/V001_CreateEShopDB.sql` T-SQL 腳本，一次建立 eShopDB 資料庫、7 張資料表、所有外鍵關聯，並填入種子資料（4 分類、8 商品、2 Banner、1 管理員帳號）。腳本採冪等性設計（IF NOT EXISTS），可重複執行不產生錯誤。

## Technical Context

**Language/Version**: T-SQL（SQL Server 2016+，支援 DATETIME2、序列識別碼）
**Primary Dependencies**: SQL Server（本機 Windows，Integrated Security）
**Storage**: SQL Server — 資料庫名稱 `eShopDB`
**Testing**: 人工驗證（執行腳本後以 SSMS 或 sqlcmd 查詢資料表結構與筆數）
**Target Platform**: Windows SQL Server（本機開發環境）
**Project Type**: 資料庫初始化腳本（DDL + DML）
**Performance Goals**: N/A（一次性初始化腳本，執行時間秒內完成）
**Constraints**: 腳本必須冪等（可重複執行）；禁止 DROP TABLE 破壞現有資料；種子密碼需以 PBKDF2 雜湊格式儲存
**Scale/Scope**: 7 張資料表，15 筆種子資料

## Constitution Check

*GATE: 依據 AGENTS.md 規範逐項檢核，必須全部通過才能進入 Phase 0。*

| # | 規範項目 | 狀態 | 說明 |
|---|---------|------|------|
| 1 | 資料庫腳本放置於 `DatabaseScripts/` 資料夾，命名格式 `V{版號}_{說明}.sql` | ✅ PASS | 腳本命名為 `V001_CreateEShopDB.sql` |
| 2 | 資料表名稱：複數、PascalCase | ✅ PASS | `Users`、`Products`、`Orders` 等 |
| 3 | 主鍵：`Id`（int IDENTITY） | ✅ PASS | 所有資料表均採 `Id INT IDENTITY(1,1)` |
| 4 | 外鍵命名：`{ReferencedTable}Id` | ✅ PASS | `CategoryId`、`UserId`、`OrderId` 等 |
| 5 | 時間欄位型別使用 `DATETIME2` | ✅ PASS | `CreatedAt`、`UpdatedAt`、`ExpiresAt` 均用 `DATETIME2` |
| 6 | 軟刪除欄位：`IsDeleted BIT NOT NULL DEFAULT 0` | ✅ PASS | `Users`、`Categories`、`Products` 含此欄位 |
| 7 | 禁止使用 `dotnet` CLI | ✅ PASS | 純 T-SQL 腳本，不涉及 .NET CLI |
| 8 | 每次 commit 前須確認 msbuild 建置成功 | ✅ PASS | 純腳本 commit，不影響 .NET 建置 |

**Gate 結論**: 所有項目通過，無違反規範，進入 Phase 0 研究階段。

## Project Structure

### Documentation (this feature)

```text
specs/001-db-init-script/
├── plan.md              # 本檔案（/speckit.plan 指令輸出）
├── research.md          # Phase 0 輸出
├── data-model.md        # Phase 1 輸出
├── quickstart.md        # Phase 1 輸出
└── checklists/
    └── requirements.md  # 規格品質檢查清單
```

### Source Code (repository root)

```text
DatabaseScripts/
└── V001_CreateEShopDB.sql   # 本功能唯一產出的原始碼
```

**Structure Decision**: 本功能為純資料庫腳本，不涉及 C# 程式碼變更。所有輸出集中於 `DatabaseScripts/` 資料夾，符合 AGENTS.md 規範。

## Complexity Tracking

> 本功能無 Constitution 違反，不需填寫。
