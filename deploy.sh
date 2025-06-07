#!/usr/bin/env bash

# 配置区
BLOG_DIR="/Users/dianyin/Desktop/kindyourself_blog"  # 替换为实际路径
SOURCE_BRANCH="blog-source"

cd "$BLOG_DIR" || { echo "❌ 无法进入目录: $BLOG_DIR"; exit 1; }

# Hexo操作
echo "===== 生成静态文件 ====="
hexo clean && hexo generate

echo "===== 部署到GitHub Pages ====="
hexo deploy

# 源文件备份
echo "===== 备份源文件 ====="
git add .

# 检查是否有变更
if git diff-index --quiet HEAD --; then
    echo "没有变更需要提交"
else
    git commit -m "自动备份: $(date +"%Y-%m-%d %H:%M:%S")"
    
    # 添加重试逻辑
    for i in {1..3}; do
        echo "尝试推送 ($i/3)..."
        if git push origin main:$SOURCE_BRANCH; then
            echo "✅ 备份成功"
            break
        else
            echo "🔄 尝试 $i/3 失败，10秒后重试..."
            sleep 10
        fi
    done
fi

echo "===== 部署完成 ====="
echo "博客地址: https://kindyourself.github.io"
echo "源文件仓库: https://github.com/kindyourself/kindyourself.github.io/tree/$SOURCE_BRANCH"
