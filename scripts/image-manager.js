// scripts/image-manager.js
const fs = require('fs');
const path = require('path');

// 添加初始化日志
hexo.log.info('[image-manager] 脚本已加载');

// 注册生成器 - 确保图片被复制
hexo.extend.generator.register('image-generator', function(locals) {
  const sourceImage = path.join(hexo.source, '_posts', 'images', 'widget_two.png');
  const publicImage = 'images/widget_two.png';
  
  // 检查源文件是否存在
  if (!fs.existsSync(sourceImage)) {
    hexo.log.info('[image-manager] 源图片不存在');
    hexo.log.error(`[image-manager] 源图片不存在: ${sourceImage}`);
    return {};
  }
  
  hexo.log.info(`[image-manager] 注册图片: ${publicImage}`);
  
  return {
    path: publicImage,
    data: function() {
      return fs.createReadStream(sourceImage);
    }
  };
});

// 注册过滤器 - 修正文章中的图片路径
hexo.extend.filter.register('after_post_render', function(data) {
  if (data.layout === 'post') {
    hexo.log.info(`[image-manager] 处理文章: ${data.title}`);
    data.content = data.content.replace(
      /!\[(.*?)\]\((.*?)\)/g, 
      (match, alt, imgPath) => {
        if (imgPath.includes('widget_two')) {
          const newPath = `/images/${path.basename(imgPath)}`;
          hexo.log.info(`[image-manager] 替换路径: ${imgPath} -> ${newPath}`);
          return `![${alt}](${newPath})`;
        }
        return match;
      }
    );
  }
  return data;
});
