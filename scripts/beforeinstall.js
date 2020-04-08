
var resp = {
  result: 0,
  ssl: !!jelastic.billing.account.GetQuotas('environment.jelasticssl.enabled').array[0].value,
  nodes: [{
    nodeType: "storage",
    flexibleCloudlets: ${settings.st_flexibleCloudlets:8},
    fixedCloudlets: ${settings.st_fixedCloudlets:1},
    diskLimit: ${settings.st_diskLimit:100},
    nodeGroup: "storage",
    displayName: "Storage"
  }]
}

if (${settings.galera:false}) {
  resp.nodes.push({
    nodeType: "mariadb-dockerized",
    tag: "10.3.22",
    count: 3,
    flexibleCloudlets: ${settings.db_flexibleCloudlets:16},
    fixedCloudlets: ${settings.db_fixedCloudlets:1},
    diskLimit: ${settings.db_diskLimit:10},
    nodeGroup: "sqldb",
    displayName: "Galera cluster",
    restartDelay: 5,
    skipNodeEmails: true,
    env: {
      ON_ENV_INSTALL: ""
    }
  })
}

if (!${settings.galera:false}) {
  resp.nodes.push({
    nodeType: "mariadb-dockerized",
    tag: "10.3.22",
    count: 2,
    flexibleCloudlets: ${settings.db_flexibleCloudlets:16},
    fixedCloudlets: ${settings.db_fixedCloudlets:1},
    diskLimit: ${settings.db_diskLimit:10},
    nodeGroup: "sqldb",
    skipNodeEmails: true,
    displayName: "DB Server"
  })
}

if (${settings.ls-addon:false}) {
  resp.nodes.push({
    nodeType: "litespeedadc",
    tag: "2.7",
    count: 1,
    flexibleCloudlets: ${settings.bl_flexibleCloudlets:8},
    fixedCloudlets: ${settings.bl_fixedCloudlets:1},
    diskLimit: ${settings.bl_diskLimit:10},
    nodeGroup: "bl",
    scalingMode: "STATEFUL",
    displayName: "Load balancer",
    addons: ["cache-purge"],
    env: {
      WP_PROTECT: "OFF"
    }
  }, {
    nodeType: "litespeedphp",
    tag: "5.4.6-php-7.3.15",
    count: ${settings.cp_count:2},
    flexibleCloudlets: ${settings.cp_flexibleCloudlets:16},
    fixedCloudlets: ${settings.cp_fixedCloudlets:1},
    diskLimit: ${settings.cp_diskLimit:10},
    nodeGroup: "cp",
    scalingMode: "STATELESS",
    displayName: "AppServer",
    addons: ["setup-site-url"],
    env: {
      SERVER_WEBROOT: "/var/www/webroot/ROOT",
      REDIS_ENABLED: "true",
      WAF: "${settings.waf:false}",
      WP_PROTECT: "OFF"
    },
    volumes: [
      "/var/www/webroot/ROOT"
    ],  
    volumeMounts: {
      "/var/www/webroot/ROOT": {
        readOnly: "false",
        sourcePath: "/data/ROOT",
        sourceNodeGroup: "storage"
      }
    }
  })
}

if (!${settings.ls-addon:false}) {
  resp.nodes.push({
    nodeType: "varnish",
    tag: "6.3.2",
    count: 1,
    flexibleCloudlets: ${settings.bl_flexibleCloudlets:8},
    fixedCloudlets: ${settings.bl_fixedCloudlets:1},
    diskLimit: ${settings.bl_diskLimit:10},
    nodeGroup: "bl",
    scalingMode: "STATEFUL",
    displayName: "Load balancer"
  }, {
    nodeType: "nginxphp",
    tag: "1.16.1-php-7.3.14",
    count: ${settings.cp_count:2},
    flexibleCloudlets: ${settings.cp_flexibleCloudlets:8},                  
    fixedCloudlets: ${settings.cp_fixedCloudlets:1},
    diskLimit: ${settings.cp_diskLimit:10},
    nodeGroup: "cp",
    scalingMode: "STATELESS",
    displayName: "AppServer",
    env: {
      SERVER_WEBROOT: "/var/www/webroot/ROOT",
      REDIS_ENABLED: "true"
    },
    volumes: [
      "/var/www/webroot/ROOT"
    ],  
    volumeMounts: {
      "/var/www/webroot/ROOT": {
        readOnly: "false",
        sourcePath: "/data/ROOT",
        sourceNodeGroup: "storage"
      }
    }
  })
}

return resp;
