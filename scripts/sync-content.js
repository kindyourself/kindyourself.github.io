const fs = require('fs-extra');

hexo.extend.filter.register('before_generate', () => {
  // 同步共享内容到 gavin 站点
  fs.copySync('source/_posts', 'source_gavin/_posts');
  fs.copySync('source/images', 'source_gavin/images');
  
  // 添加 gavin 专属内容
  fs.copySync('source/_posts_gavin', 'source_gavin/_posts');
  fs.copySync('source/gavin', 'source_gavin/gavin');
  
  hexo.log.info('内容同步完成');
});