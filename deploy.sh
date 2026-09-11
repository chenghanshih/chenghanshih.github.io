#!/bin/bash

# Hugo 網站自動部署腳本 (Mac 版本)
# 使用方法: ./deploy.sh

echo "🚀 開始部署 Hugo 網站..."

# 檢查是否在正確的目錄
if [ ! -f "hugo.toml" ] && [ ! -f "config.toml" ]; then
    echo "❌ 錯誤：請在 Hugo 專案根目錄執行此腳本"
    exit 1
fi

# 清理舊的 public 目錄
echo "🧹 清理舊的建置文件..."
rm -rf public

# 建置網站
echo "🔨 建置 Hugo 網站..."
hugo

# 檢查建置是否成功
if [ $? -ne 0 ]; then
    echo "❌ Hugo 建置失敗"
    exit 1
fi

# 進入 public 目錄
cd public

# 初始化 git（如果需要）
if [ ! -d ".git" ]; then
    echo "📦 初始化 Git 倉庫..."
    git init
    git remote add origin https://github.com/hans0803/hans0803.github.io.git
fi

# 添加所有文件
echo "📝 添加文件到 Git..."
git add .

# 生成提交訊息（包含時間戳）
COMMIT_MSG="部署更新 - $(date '+%Y-%m-%d %H:%M:%S')"

# 提交變更
echo "💾 提交變更..."
git commit -m "$COMMIT_MSG"

# 推送到 GitHub Pages
echo "🌐 推送到 GitHub Pages..."
git push -u origin main --force

# 檢查推送是否成功
if [ $? -eq 0 ]; then
    echo "✅ 部署完成！"
    echo "🔗 您的網站將在幾分鐘內更新：https://hans0803.github.io"
else
    echo "❌ 推送失敗，請檢查網路連線和 GitHub 權限"
    exit 1
fi

# 返回專案根目錄
cd ..

echo "🎉 部署流程完成！" 