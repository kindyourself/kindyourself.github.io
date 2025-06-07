#!/usr/bin/env bash

# ===== 配置区 =====
BLOG_DIR="/Users/dianyin/Desktop/kindyourself_blog"  # 修改为实际路径
DEPLOY_BRANCH="master"             # 静态文件部署分支
SOURCE_BRANCH="main"               # 源文件分支
# ==================

cd "$BLOG_DIR" || { echo "目录不存在: $BLOG_DIR"; exit 1; }

# 生成并部署静态文件
echo "正在生成静态文件..."
hexo clean && hexo generate

echo "正在部署到GitHub Pages..."
hexo deploy

# 备份源文件
echo "正在备份源文件..."
git add .
git commit -m "自动备份: $(date +"%Y-%m-%d %H:%M:%S")" --allow-empty
git push origin "$SOURCE_BRANCH"

echo "===== 部署完成 ====="
echo "博客地址: https://kindyourself.github.io"
echo "源文件仓库: https://github.com/kindyourself/blog-source"
