#!/usr/bin/env bash

# 配置区
BLOG_DIR="/Users/dianyin/Desktop/blog"  # 替换为你的博客路径
REPOS=(
  "kind:git@github.com:kindyourself/kindyourself.github.io.git:master"
  "gavin:git@github.com-second:gavincarter1991/gavincarter1991.github.io.git:master"
)

cd "$BLOG_DIR" || { echo "❌ 无法进入博客目录"; exit 1; }

# Hexo 操作
echo "===== 清理 & 生成静态文件 ====="
hexo clean
hexo generate

# 多仓库部署
for repo in "${REPOS[@]}"; do
  IFS=':' read -r name url branch <<< "$repo"
  echo "===== 部署到 $name 仓库 ====="
  
  # 创建临时配置
  tmp_config="_config_$name.yml"
  echo "deploy:" > $tmp_config
  echo "  - type: git" >> $tmp_config
  echo "    repo: $url" >> $tmp_config
  echo "    branch: $branch" >> $tmp_config
  
  # 执行部署
  hexo deploy --generate --config $tmp_config
  rm $tmp_config
done

# 源文件备份
current_branch=$(git branch --show-current)
if [ "$current_branch" != "blog-source" ]; then
  git checkout blog-source || git checkout -b blog-source
fi

git add --all .
if ! git diff-index --quiet HEAD --; then
  git commit -m "自动备份: $(date +"%Y-%m-%d %H:%M:%S")"
  git push origin blog-source
fi

# 切回原分支
git checkout $current_branch

echo "===== 部署完成 ====="
echo "博客地址:"
echo "1. https://kindyourself.github.io"
echo "2. https://gavincarter1991.github.io"
