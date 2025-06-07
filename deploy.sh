#!/bin/bash

# 设置绝对路径
BLOG_DIR="/Users/dianyin/Desktop/kindyourself_blog"  # 替换为实际路径

# 进入博客目录
cd "$BLOG_DIR" || exit 1

# Hexo操作
hexo clean
hexo generate
hexo deploy

# 源文件备份
git add .
git commit -m "自动备份: $(date +"%Y-%m-%d %H:%M")"
git push origin main
