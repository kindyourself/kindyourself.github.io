// scripts/fix-image-path.js
const path = require('path');
const url = require('url');

hexo.extend.filter.register('after_post_render', function(data) {
  // 处理中文路径问题
  const encodePath = (str) => {
    return str.split('/').map(segment => 
      segment === encodeURIComponent(segment) ? segment : encodeURIComponent(segment)
    ).join('/');
  };

  // 处理图片路径
  data.content = data.content.replace(
    /!\[(.*?)\]\((.*?)\)/g, 
    (match, alt, imgPath) => {
      // 跳过网络图片
      if (imgPath.startsWith('http') || imgPath.startsWith('/') || imgPath.startsWith('.')) {
        return match;
      }
      
      // 获取文章路径
      const postPath = path.dirname(data.path);
      
      // 构建正确路径并编码中文
      const encodedPath = encodePath(`${postPath}/${imgPath}`);
      
      return `![${alt}](${encodedPath})`;
    }
  );
  
  return data;
});