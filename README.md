# Auto-Scalable Magento Cluster

The Magento Cluster is an advanced eCommerce solution for those who aim for growth and want to get the most out of their installation. The package offers such features as high availability, auto-scalability, high-performance web server and load balancing stacks, auto-renewable SSL, and more.

## Magento Cluster Topology

<p align="center"> 
<img src="https://github.com/jelastic-jps/magento-cluster/blob/v2.2.0/images/magento-topology-v2.png" width="400">
</p>

Premium Magento is a PHP based eCommerce platform that is packaged as an advanced, highly-reliable, and auto-scalable cluster on top of certified Jelastic stack templates with the following topology and peculiarities:
- **Premium CDN** - integration with the [Edgecast CDN](https://jelastic.com/blog/enterprise-cdn-verizon-integration/) network provides a lightning-fast user experience and ensures higher search engines rank with advanced caching and acceleration strategies, massive bandwidth capacity, [HTTP/3](https://docs.jelastic.com/http3/) support
- [**Let's Encrypt SSL**](https://jelastic.com/blog/free-ssl-certificates-with-lets-encrypt/) the add-on provides automation for all the SSL certificate management operations - trusted certificate issuing, custom domain validation, automatic certificate renewal
- [**LiteSpeed Web ADC**](https://docs.jelastic.com/litespeed-web-adc/) advanced load balancer with flexible traffic distribution algorithm (to optimize performance), modern HTTP/3 protocol support, and ESI dynamic cache (to serve dynamic requests directly reducing the number of requests to backend servers) 
- [**LiteSpeed Web Server**](https://docs.jelastic.com/litespeed-web-server/) a high-performance web server with a wide feature set, such as HTTP/3 support, ESI cache, CSS and JavaScript optimization, image optimization, browser and object cache support, CDN support, built-in WAF, Geo-DNS, CAPTCHA, IP throttling, cutting-edge anti-DDoS protection, etc.
- [**Web Application Firewall**](https://www.litespeedtech.com/support/wiki/doku.php/litespeed_wiki:waf) (WAF) a security feature for the LiteSpeed Web Server stacks that comes with Layer-7 Anti-DDoS Filtering, IP level bandwidth, and request rate throttling
- [**LiteMage Cache**](https://www.litespeedtech.com/products/cache-plugins/magento-acceleration) enhanced caching solution for dynamic assets that allows storing them as static ones to significantly speed up the requests serving
- **MariaDB Cluster** the primary-primary replication topology offers better performance for storing dynamic content and a simpler failover procedure
- **Redis** a high-performance RAM-allocated caching solution that is running inside the LiteSpeed Web Server container to store already loaded database query results and serve them up faster per request
- [**OpenSearch**](https://opensearch.org/) a community-driven, open-source search engine (based on the Jelastic OpenSearch certified template) that provides a distributed, multitenant-capable full-text search
- [**Data Storage**](https://docs.jelastic.com/data-storage-container) node for media files

## Deployment to the Cloud
Click the **Deploy** button below, specify your email address within the widget, choose one of the [Jelastic Public Cloud providers](https://jelastic.com/install-application/?manifest=https://raw.githubusercontent.com/jelastic-jps/magento-cluster/v2.2.0/manifest.yml&keys=app.jelastic.eapps.com;app.cloud.hostnet.nl;app.jelastichosting.nl;app.appengine.flow.ch;app.jelasticlw.com.br;app.mircloud.host;app.jcs.opusinteractive.io;app.paas.quarinet.eu) and press **Install**.

[![Deploy](images/deploy-to-jelastic.png)](https://jelastic.com/install-application/?manifest=https://raw.githubusercontent.com/jelastic-jps/magento-cluster/v2.2.0/manifest.yml&keys=app.jelastic.elastx.net;app.milesweb.cloud;app.jelastic.eapps.com;app.jelastic.saveincloud.net&filter=auto_cluster)

*Note:* If you are already registered at Jelastic, you can deploy this cluster by importing [the package manifest raw link](https://raw.githubusercontent.com/jelastic-jps/magento-cluster/v2.2.0/manifest.yml) within the dashboard.

## Installation Process
Before the installation, the package provides a dialog that includes customization options for the Magento cluster.

<p align="center"> 
<img src="https://github.com/jelastic-jps/magento-cluster/blob/master/images/magento-installation.png" width="400">
</p>

Based on the expected cluster load level, select the Scaling Strategy to determine the automatic horizontal scaling options (can be re-adjust manually):
**Low Load**
- adds **1** application server node if the workload is higher than **70%**
- removes **1** application server node if the workload goes below **20%**
**Medium Load**
- adds **1** application server node if the workload is higher than **50%**
- removes **1** application server node if the workload goes below **20%**
**High Load**
- adds **2** application server nodes if the workload is higher than **30%**
- removes **1** application server node if the workload goes below **10%**

Choose the required **Advances Features** for your cluster:
- **Web Application Firewall** - enables security option for malicious requests filtering (the feature available with the *LiteSpeed Web Server* only). 
- **Install Let’s Encrypt SSL with Auto-Renewal** - installs the *Let's Encrypt* add-on to issue a trusted SSL certificate for a custom domain. The add-on also manages domain validation, certificates renewal, and SSL-related notifications.
- **Install Lightning-Fast Premium CDN** - installs the *Premium CDN* add-on to integrate Edgecast CDN into the Magento application.



Once the deployment is finished, you’ll see the appropriate success pop-up with access credentials to your administration Magento panel, whilst the same information will be duplicated to your email box.

<p align="center"> 
<img src="https://github.com/jelastic-jps/magento-cluster/blob/master/images/magento-successful-install.png" width="400">
</p>

So now you can just click on the **Open in browser** button within the shown frame and start filling your highly available and reliable Magento installation with the required content, being ready to handle as much users as your service requires.
