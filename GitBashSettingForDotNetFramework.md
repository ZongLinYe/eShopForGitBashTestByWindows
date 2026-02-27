# Windows + .NET Framework + MSBuild + Git Bash 環境設定筆記

**適用情境**：在 Windows 上使用 Git Bash 終端機開發 .NET Framework 4.6.x 專案，需要以 `msbuild` 指令建置方案（`.slnx` / `.sln`）。

---

## 問題根源

Git Bash 是基於 MSYS2 的 Unix-like 環境，預設不包含 Visual Studio 工具鏈的 PATH。因此：

| 症狀 | 原因 |
|------|------|
| 輸入 `msbuild` 出現 `command not found` | MSBuild 路徑不在 `$PATH` |
| 直接加入 PATH 後 `/p:` 或 `/t:` 參數被轉換 | Git Bash 的 MSYS 路徑轉換機制誤判 Windows 參數 |

> **為什麼不用 `dotnet` CLI？**
> `.NET Framework` 專案只能用 `msbuild` 建置，`dotnet build` 僅適用於 .NET Core / .NET 5+ 專案。

---

## 解決方案：`~/.bash_profile` 設定 Alias

這是本專案採用的方式，**一次設定，永久生效**。

### Step 1：確認 MSBuild 路徑

MSBuild 位於 Visual Studio 的安裝目錄下，請依你安裝的版本對應路徑：

| Visual Studio 版本 | 路徑 |
|--------------------|------|
| **VS 2026** Community（本專案） | `C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe` |
| VS 2022 Community | `C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe` |
| VS 2022 Professional / Enterprise | 將 `Community` 改為 `Professional` 或 `Enterprise` |

> 不確定路徑時，可在 PowerShell 執行：
> ```powershell
> & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe
> ```

### Step 2：加入 Alias 至 `~/.bash_profile`

```bash
# 開啟（或建立）設定檔
nano ~/.bash_profile
```

加入以下這一行（`MSYS_NO_PATHCONV=1` 是關鍵，說明見下方）：

```bash
# MSBuild alias for .NET Framework projects（VS 2026 Community）
alias msbuild='MSYS_NO_PATHCONV=1 "/c/Program Files/Microsoft Visual Studio/18/Community/MSBuild/Current/Bin/MSBuild.exe"'
```

儲存後讓設定立即生效：

```bash
source ~/.bash_profile
```

### Step 3：驗證設定

```bash
msbuild --version
# 預期輸出類似：
# .NET Framework 的 MSBuild 版本 18.x.x-release...
```

---

## `MSYS_NO_PATHCONV=1` 是什麼？

Git Bash（MSYS2）有一個「路徑自動轉換」機制：凡是看起來像 Unix 路徑的字串（以 `/` 開頭），都會被自動轉換為 Windows 路徑。

這會導致 MSBuild 的 `/p:` `/t:` `/v:` 等參數被誤轉：

```bash
# 沒有 MSYS_NO_PATHCONV=1 時，Git Bash 會把這樣的指令：
msbuild eShop.slnx /p:Configuration=Debug

# 誤轉成：
msbuild eShop.slnx "C:/p:Configuration=Debug"   ← 錯誤！
```

加上 `MSYS_NO_PATHCONV=1` 環境變數，即可停用該次命令的路徑轉換，讓 MSBuild 參數原封不動傳入。

---

## 本專案的建置腳本：`build.sh`

本專案在根目錄提供 `build.sh`，封裝了完整建置邏輯，**不需要手動輸入 msbuild 長指令**：

```bash
#!/bin/bash -l
# -l（login shell）確保 ~/.bash_profile 的 alias 被載入
# 使用方式：bash build.sh [Debug|Release]
# 預設為 Debug 模式
CONFIGURATION=${1:-Debug}

# 由於 Git Bash 無法正確掃描含空格的 PATH，直接在這裡指定 MSBuild 路徑（與 alias 相同）
MSBUILD="/c/Program Files/Microsoft Visual Studio/18/Community/MSBuild/Current/Bin/MSBuild.exe"

echo "=== eShop msbuild 開始 (Configuration: $CONFIGURATION) ==="

# MSYS_NO_PATHCONV=1 防止 Git Bash 誤轉 /p: /v: /clp: 參數
MSYS_NO_PATHCONV=1 "$MSBUILD" eShop.slnx \
    /p:Configuration=$CONFIGURATION \
    /v:minimal \
    /clp:ErrorsOnly

if [ $? -eq 0 ]; then
    echo "=== 建置成功 ==="
else
    echo "=== 建置失敗 ==="
    exit 1
fi
```

### 使用方式

```bash
# 切換至專案根目錄（與 eShop.slnx 同層）
cd /d/VSCodeProject/GitBashWithMsbuildTest/eShop

# Debug 建置（預設）
bash build.sh

# Release 建置
bash build.sh Release
```

### 成功輸出範例

```
=== eShop msbuild 開始 (Configuration: Debug) ===
.NET Framework 的 MSBuild 版本 18.3.0-release-26070-10+3972042b7
=== 建置成功 ===
```

---

## 常見問題

**Q：`bash build.sh` 還是出現 `msbuild: command not found`？**
`build.sh` 使用 `#!/bin/bash -l`（login shell），理論上會自動載入 `~/.bash_profile`。若仍失敗，請確認：
1. alias 是否確實寫在 `~/.bash_profile`（而非 `~/.bashrc`）
2. 執行 `source ~/.bash_profile` 後再試一次

**Q：切換到 VS 2022 或其他版本後建置失敗？**
修改 `build.sh` 第 7 行的 `MSBUILD` 路徑，以及 `~/.bash_profile` 中的 alias 路徑，對應到新版本的安裝目錄即可。

**Q：為何不直接把 MSBuild 加入 `$PATH`？**
在 Git Bash 中，即使 MSBuild 在 PATH 裡，`MSYS_NO_PATHCONV` 仍需在每次呼叫時設定，否則參數會被誤轉。使用 alias 將兩者一起封裝是最乾淨的做法。

