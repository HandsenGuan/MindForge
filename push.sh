#!/bin/bash

# MindForge - 推送到 GitHub 脚本

echo "🚀 MindForge 推送到 GitHub"
echo "================================"

# 检查是否已经添加了 remote
if git remote -v | grep -q "origin"; then
    echo "✅ 已检测到 remote origin"
else
    echo "❌ 未检测到 remote，请先在 GitHub 创建仓库"
    echo ""
    echo "请按以下步骤操作："
    echo "1. 访问 https://github.com/new"
    echo "2. Repository name: MindForge"
    echo "3. Description: 🤖 MindForge - AI增强型个人知识归档仓库"
    echo "4. 不要勾选 README、.gitignore、license"
    echo "5. 点击 Create repository"
    echo ""
    echo "创建后，运行："
    echo "  git remote add origin https://github.com/YOUR_USERNAME/MindForge.git"
    echo "  git push -u origin master"
    exit 1
fi

echo ""
echo "准备推送到 GitHub..."
echo ""

# 执行推送
git push -u origin master

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 推送成功！"
    echo "请访问 https://github.com 查看你的 MindForge 项目"
else
    echo ""
    echo "❌ 推送失败，请检查："
    echo "1. GitHub 用户名和 Token 是否正确"
    echo "2. 仓库是否已创建"
    echo "3. 网络连接是否正常"
fi
