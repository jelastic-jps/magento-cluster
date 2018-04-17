<?php
return array (
  'backend' =>
  array (
    'frontName' => 'admin',
  ),
  'crypt' =>
  array (
    'key' => 'de7fc043d94949818bbe40cba5b2fde4',
  ),

'session' =>
   array (
      'save' => 'memcached',
      'save_path' => 'MEMCACHE:11211'
),



    'cache' =>
        array (
            'frontend' => array(
                'default' => array(
                    'backend' => 'Cm_Cache_Backend_Redis',
                    'backend_options' => array(
                        'server' => 'REDIS',            // or absolute path to unix socket
                        'port' => '6379',
                        'persistent' => '',                 // Specify a unique string like "cache-db0" to enable persistent connections.
                        'database' => '0',
                        'password' => '',
                        'force_standalone' => '0',          // 0 for phpredis, 1 for standalone PHP
                        'connect_retries' => '1',           // Reduces errors due to random connection failures
                        'read_timeout' => '10',             // Set read timeout duration
                        'automatic_cleaning_factor' => '0', // Disabled by default
                        'compress_data' => '1',             // 0-9 for compression level, recommended: 0 or 1
                        'compress_tags' => '1',             // 0-9 for compression level, recommended: 0 or 1
                        'compress_threshold' => '20480',    // Strings below this size will not be compressed
                        'compression_lib' => 'gzip',        // Supports gzip, lzf and snappy,
                        'use_lua' => '0'                    // Lua scripts should be used for some operations
                    )
                )
            )
        ),




  'db' =>
  array (
    'table_prefix' => '',
    'connection' =>
    array (
      'default' =>
      array (
        'host' => 'DB_MASTER',
        'dbname' => '_DBNAME_',
        'username' => '_DBUSER_',
        'password' => '_DBPASS_',
        'model' => 'mysql4',
        'engine' => 'innodb',
        'initStatements' => 'SET NAMES utf8;',
        'active' => '1',
      ),
    ),


        'slave_connection' =>
            array (
                'default' =>
                    array (
                        // HaProxy Read (slave) connection
                        'host' => 'DB_SLAVE',
                        'dbname' => '_DBNAME_',
                        'username' => '_DBUSER_',
                        'password' => '_DBPASS_',
                        'active' => '1',
                    ),
            ),



  ),
  'resource' =>
  array (
    'default_setup' =>
    array (
      'connection' => 'default',
    ),
  ),
  'x-frame-options' => 'SAMEORIGIN',
  'MAGE_MODE' => 'default',
  'cache_types' =>
  array (
    'config' => 1,
    'layout' => 1,
    'block_html' => 1,
    'collections' => 1,
    'reflection' => 1,
    'db_ddl' => 1,
    'eav' => 1,
    'customer_notification' => 1,
    'full_page' => 1,
    'config_integration' => 1,
    'config_integration_api' => 1,
    'translate' => 1,
    'config_webservice' => 1,
  ),
  'install' =>
  array (
    'date' => 'Fri, 15 Sep 2017 14:41:38 +0000',
  ),
);
