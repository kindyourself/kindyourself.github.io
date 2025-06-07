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
