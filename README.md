![Magento Cluster](/images/magento.png)
# Magento Cluster
The JPS package deploy Magento 2 that initially contains 2 balancers, 2 application servers, 2 MySQL databases, 2 Memcached 1 storage container.

##Highlights
Get your highly available and scalable clustered solution for Magento, the extremely popular open source e-commerce platform. This package is designed to ensure the load tracking and distribution, as well as automatic adjusting the amount of allocated resources according to it.

##Environment Topology
![Cluster Topology](images/topology.png)

##Specifics
 Layer | Server          | Number of CTs <br/> by default | Cloudlets per CT <br/> (reserved/dynamic) | Options
-----|---------------|------------------------|:---------------------------------:|:-----:
LB   |      Nginx      | 2 | 1/8 |-
AS   | Nginx (PHP-FPM) | 2 | 1/8 |-
DB   |      MySQL      | 2 | 1/8 |-
CH   |     Memcached   | 2 | 1/8 |-
ST   |  Shared Storage | 1 | 1/8 |-

* LB - Load balancer
* AS - Application server
* DB - Database
* CH - Cache
* ST - Shared Storage
* CT - Container

**Magento Version**: 2.0.4<br/>
**Varnish Version**: 4.1.1<br/>
**Nginx Version**: 1.8.0<br/>
**Php Version**: PHP 5.6.20<br/>
**MySQL Database**: 5.6.31<br/>
**Memcached Version**: 1.4.15
