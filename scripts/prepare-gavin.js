hexo.extend.filter.register('before_generate', () => {
  // 复制共享文章
  hexo.log.info('准备 gavin 博客内容');
  fs.copySync('source/_posts', 'source_gavin/_posts');
  
  // 添加专属文章
  fs.copySync('source/_posts_gavin', 'source_gavin/_posts');
});