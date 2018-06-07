<?php
return array (
  'backend' =>
  array (
    'frontName' => 'admin',
  ),
  'crypt' =>
  array (
    'key' => 'f570d743c4f353262b241ef4122f13bb',
  ),

'session' =>
array (
  'save' => 'redis',
  'redis' =>
  array (
    'host' => 'RDS',
    'port' => '6379',
    'password' => 'RD_SESSION_PASS',
    'timeout' => '2.5',
    'persistent_identifier' => '',
    'database' => '2',
    'compression_threshold' => '2048',
    'compression_library' => 'gzip',
    'log_level' => '3',
    'max_concurrency' => '6',
    'break_after_frontend' => '5',
    'break_after_adminhtml' => '30',
    'first_lifetime' => '600',
    'bot_first_lifetime' => '60',
    'bot_lifetime' => '7200',
    'disable_locking' => '0',
    'min_lifetime' => '60',
    'max_lifetime' => '2592000'
  )
),
'cache' =>
array(
   'frontend' =>
   array(
      'default' =>
      array(
         'backend' => 'Cm_Cache_Backend_Redis',
         'backend_options' =>
         array(
            'server' => 'RDC',
            'password' => 'RD_CACHE_PASS',
            'database' => '0',
            'port' => '6379'
            ),
    ),
    'page_cache' =>
    array(
      'backend' => 'Cm_Cache_Backend_Redis',
      'backend_options' =>
       array(
         'server' => 'RDC',
         'port' => '6379',
         'password' => 'RD_CACHE_PASS',
         'database' => '1',
         'compress_data' => '0'
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
        'host' => 'DB_SLAVE',
        'dbname' => '_DBNAME_',
        'username' => '_DBUSER_',
        'password' => '_DBPASS_',
        'active' => '1',
      ),
    ),
    'table_prefix' => '',
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
    'date' => 'Wed, 18 Apr 2018 08:11:54 +0000',
  ),
);
