**Magento environment**: [${globals.PROTOCOL}://${env.domain}/](${globals.PROTOCOL}://${env.domain}/)

Use the following credentials to access the admin panel:

**Admin Panel**: [${globals.PROTOCOL}://${env.domain}/admin/](${globals.PROTOCOL}://${env.domain}/admin/)  
**Login**: admin  
**Password**: ${globals.MG_ADMIN_PASS}  

Please use the following data to access LiteSpeed WebAdmin Console:

**Admin Console**: [https://${env.domain}:4848/](https://${env.domain}:4848/)   
**Login**: admin    
**Password**: ${globals.DB_PASS}  

Manage the database nodes using the next credentials:

**phpMyAdmin Panel**: [https://${env.domain}:8443/](https://${env.domain}:8443/)  
**Username**: ${globals.DB_USER}    
**Password**: ${globals.DB_PASS}  
