**Magento environment**: [${globals.PROTOCOL}://${env.domain}/](${globals.PROTOCOL}://${env.domain}/)

**CDN Endpoint URL**:  [${globals.PROTOCOL}://${globals.CDN}/](${globals.PROTOCOL}://${globals.CDN}/)

Use the following credentials to access the admin panel:

**Admin Panel**: [${globals.PROTOCOL}://${env.domain}/admin/](${globals.PROTOCOL}://${env.domain}/admin/)  
**Login**: admin  
**Password**: ${globals.MG_ADMIN_PASS}  

Manage the database nodes using the next credentials:

**phpMyAdmin Panel**: [https://node${nodes.sqldb.master.id}-${env.domain}/](https://node${nodes.sqldb.master.id}-${env.domain}/)  
**Username**: ${globals.DB_USER}    
**Password**: ${globals.DB_PASS}  

Use the following credentials to access the OpenSearch:

**Access URL**: [http://node${nodes.nosqldb.master.id}-${env.domain}:4949](http://node${nodes.nosqldb.master.id}-${env.domain}:4949)  
**Login**: admin  
**Password**: ${globals.ES_PASS}  
