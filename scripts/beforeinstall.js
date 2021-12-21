var db_cluster = '${settings.galera}' == 'true' ? "galera" : "master";
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
  nodeType: "mariadb-dockerized",
  flexibleCloudlets: ${settings.db_flexibleCloudlets:16},
  fixedCloudlets: ${settings.db_fixedCloudlets:1},
  tag: "10.4.21",
  count: 2,
  nodeGroup: "sqldb",
  restartDelay: 10,
  skipNodeEmails: true,
  cluster: {
    scheme: db_cluster,
    db_user: "${globals.DB_USER}",
    db_pass: "${globals.DB_PASS}",
    is_proxysql: false,
  },
  env: {
    SCHEME: db_cluster,
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
    ON_ENV_INSTALL: {
      jps: "https://raw.githubusercontent.com/jelastic-jps/litespeed/master/addons/license-v2.yml",
      settings: {
        modules: "true"
      }
    }
  }
}, {
  nodeType: "litespeedphp",
  count: ${settings.cp_count:2},
  engine: "php7.4",
  flexibleCloudlets: ${settings.cp_flexibleCloudlets:32},
  fixedCloudlets: ${settings.cp_fixedCloudlets:1},
  nodeGroup: "cp",
  restartDelay: 10,
  env: {
    SERVER_WEBROOT: "/var/www/webroot/ROOT",
    REDIS_ENABLED: "true",
    WAF: "${settings.waf:false}",
    WP_PROTECT: "OFF"
  }
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
