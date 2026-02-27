#!/bin/bash -l
# eShop 專案建置腳本
# -l 表示以 login shell 執行，會自動載入 ~/.bash_profile（內含 msbuild PATH）
# 使用方式：bash build.sh [Debug|Release]
# 預設為 Debug 模式

CONFIGURATION=${1:-Debug}

# 由於 Git Bash 無法正確掃描含空格的 PATH，直接指定 MSBuild 完整路徑
MSBUILD="/c/Program Files/Microsoft Visual Studio/18/Community/MSBuild/Current/Bin/MSBuild.exe"

echo "=== eShop msbuild 開始 (Configuration: $CONFIGURATION) ==="

MSYS_NO_PATHCONV=1 "$MSBUILD" eShop.slnx /p:Configuration=$CONFIGURATION /v:minimal /clp:ErrorsOnly

if [ $? -eq 0 ]; then
    echo "=== 建置成功 ==="
else
    echo "=== 建置失敗 ==="
    exit 1
fi
