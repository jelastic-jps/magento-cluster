var resp = {
  result: 0,
  nodes: []
}

resp.nodes.push({
  nodeType: "storage",
  count: 1,
  flexibleCloudlets: ${settings.st_flexibleCloudlets:8},
  fixedCloudlets: ${settings.st_fixedCloudlets:1},
  nodeGroup: "storage",
  validation: {
    maxCount: 1
   }
})

resp.nodes.push({
  nodeType: "mariadb106",
  flexibleCloudlets: ${settings.db_flexibleCloudlets:16},
  fixedCloudlets: ${settings.db_fixedCloudlets:1},
  count: 2,
  nodeGroup: "sqldb",
  restartDelay: 10,
  skipNodeEmails: true,
  cluster: {
    scheme: "master",
    db_user: "${globals.DB_USER}",
    db_pass: "${globals.DB_PASS}",
    is_proxysql: false,
  },
  env: {
    SCHEME: "master",
    DB_USER: "${globals.DB_USER}",
    DB_PASS: "${globals.DB_PASS}",
    IS_PROXYSQL: false
  }  
});

resp.nodes.push({
  nodeType: "litespeedadc",
  count: 1,
  flexibleCloudlets: ${settings.bl_flexibleCloudlets:8},
  fixedCloudlets: ${settings.bl_fixedCloudlets:1},
  nodeGroup: "bl",
  scalingMode: "STATEFUL",
  env: {
    WP_PROTECT: "OFF",
    WP_PROTECT_LIMIT: 100,
    LITEMAGE: "ON",
    HEALTH_CHECK_PATH: "health_check.php",
    ON_ENV_INSTALL: {
      jps: "https://cdn.jsdelivr.net/gh/jelastic-jps/litespeed@master/addons/license-v2.yml",
      settings: {
        modules: "true"
      }
    }
  }
}, {
  nodeType: "litespeedphp",
  count: ${settings.cp_count:2},
  engine: "php8.3",
  flexibleCloudlets: ${settings.cp_flexibleCloudlets:32},
  fixedCloudlets: ${settings.cp_fixedCloudlets:1},
  nodeGroup: "cp",
  restartDelay: 10,
  env: {
    SERVER_WEBROOT: "/var/www/webroot/ROOT",
    WAF: "${settings.waf:false}",
    WP_PROTECT: "OFF"
  }
})

resp.nodes.push({
  nodeType: "memcached-dockerized",
  count: 1,
  cloudlets: ${settings.cache.cloudlets:8},
  diskLimit: "${settings.cache.diskspace:[quota.disk.limitation]}",
  nodeGroup: "cache"
})

resp.nodes.push({
  nodeType: "opensearch",
  count: 1,
  flexibleCloudlets: ${settings.st_flexibleCloudlets:16},
  fixedCloudlets: ${settings.st_fixedCloudlets:1},
  nodeGroup: "nosqldb",
  displayName: "OpenSearch",
  cluster: {
    is_opensearchdashboards: false,
    success_email: false,
  }
})

return resp;
