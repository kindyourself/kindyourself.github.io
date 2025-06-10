hexo.extend.filter.register('after_deploy', function() {
  const sites = [
    { name: 'kindyourself', url: 'https://kindyourself.github.io/latest-post' },
    { name: 'gavincarter', url: 'https://gavincarter1991.github.io/latest-post' }
  ];
  
  sites.forEach(site => {
    require('https').get(site.url, (res) => {
      if (res.statusCode === 200) {
        hexo.log.info(`✅ ${site.name} 部署验证成功`);
      } else {
        hexo.log.error(`❌ ${site.name} 部署失败: HTTP ${res.statusCode}`);
      }
    }).on('error', (e) => {
      hexo.log.error(`❌ ${site.name} 访问错误: ${e.message}`);
    });
  });
});