#!/usr/bin/env bash

# 配置区
BLOG_DIR="/Users/dianyin/Desktop/kindyourself_blog"  # 替换为你的博客路径
PUBLIC_REPO="git@github.com:kindyourself/kindyourself.github.io.git"
PRIVATE_REPO="git@github.com:kindyourself/blog-source.git"

cd "$BLOG_DIR" || { echo "❌ 无法进入博客目录"; exit 1; }

# Hexo 操作
echo "===== 清理 & 生成静态文件 ====="
hexo clean
hexo generate

echo "===== 部署到 GitHub Pages ====="
hexo deploy

# 备份到私有仓库
echo "===== 备份源文件到私有仓库 ====="
git add .
if git diff-index --quiet HEAD --; then
    echo "无文件变更"
else
    git commit -m "自动备份: $(date +"%Y-%m-%d %H:%M:%S")"
    
    # 推送到私有仓库
    if git push "$PRIVATE_REPO" main; then
        echo "✅ 私有仓库备份成功"
    else
        echo "❌ 私有仓库备份失败，请手动检查"
    fi
fi

echo "===== 部署完成 ====="
echo "博客地址: https://kindyourself.github.io"
echo "源文件仓库: $PRIVATE_REPO (私有)"
