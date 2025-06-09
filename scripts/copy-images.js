const fs = require('fs-extra');
const path = require('path');

hexo.on('generateBefore', () => {
  const postsDir = path.join(hexo.source_dir, '_posts');
  const publicDir = hexo.public_dir;
  
  // 遍历所有文章目录
  fs.readdirSync(postsDir).forEach(file => {
    const filePath = path.join(postsDir, file);
    const stats = fs.statSync(filePath);
    
    if (stats.isFile() && ['.png', '.jpg', '.jpeg', '.gif'].includes(path.extname(file).toLowerCase())) {
      // 获取目标路径（基于日期）
      const match = file.match(/(\d{4})-(\d{2})-(\d{2})-/);
      if (match) {
        const [, year, month, day] = match;
        const targetDir = path.join(publicDir, year, month, day, path.basename(file, path.extname(file)));
        
        // 确保目标目录存在
        fs.ensureDirSync(targetDir);
        
        // 复制图片文件
        fs.copyFileSync(filePath, path.join(targetDir, file));
        hexo.log.info(`Copied image: ${file} -> ${targetDir}`);
      }
    }
  });
});