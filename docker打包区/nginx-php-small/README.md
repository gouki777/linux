# NGX+PHP DEMO  
#### 组件版本
---
openresty-1.15.8.1-1~stretch1   
php:7.1.30-fpm-stretch  
|-opcache pdo_mysql zip  [三方组件]  
|-redis mongodb   [预留，默认不安装]  
supervisord       [docker进程管理]
####  
1.修正时区和apt源  
2.优化配置文件  
3.优化nginx json log `日志尽量打有用的`  
4.优化supervisord,详见supervisor.conf
   
日志样式  
`完整的日志有助于排错`,包括前端响应,后端响应，UA Cookie referer,range等信息
如下：
```
kubectl logs -f -n test-k8s-loda ngxphp-sjwlr  
{ "@timestamp": "2019-08-12T14:45:34+08:00", "remote_addr": "10.249.188.112", "bytes": "108", "request_time": "0.003", "status": "200", "http_request": "http://hellotest.php.org:80/hello.php", "method": "GET", "protocol": "HTTP/1.1", "http_range": "-", "referer": "-", "user_agent":"Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3423.2 Safari/537.36", "cookie": "-", "x_forwarded_for": "172.30.50.166", "upstream_addr": "127.0.0.1:9000", "upstream_response_time": "0.003", "upstream_status": "200" }
{ "@timestamp": "2019-08-12T14:45:44+08:00", "remote_addr": "10.249.188.112", "bytes": "84488", "request_time": "0.003", "status": "200", "http_request": "http://hellotest.php.org:80/info.php", "method": "GET", "protocol": "HTTP/1.1", "http_range": "-", "referer": "-", "user_agent":"Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3423.2 Safari/537.36", "cookie": "-", "x_forwarded_for": "172.30.50.166", "upstream_addr": "127.0.0.1:9000", "upstream_response_time": "0.003", "upstream_status": "200" }
{ "@timestamp": "2019-08-12T14:47:48+08:00", "remote_addr": "10.249.188.112", "bytes": "108", "request_time": "0.002", "status": "200", "http_request": "http://hellotest.php.org:80/hello.php", "method": "GET", "protocol": "HTTP/1.1", "http_range": "-", "referer": "-", "user_agent":"Mozilla/5.0 (Windows NT 10.0; WOW64; rv:56.0) Gecko/20100101 Firefox/56.0", "cookie": "__tad=1564986333.5324221; tu=f6eb68484646d3594a7a92c74c6bc4b7", "x_forwarded_for": "172.30.50.166", "upstream_addr": "127.0.0.1:9000", "upstream_response_time": "0.002", "upstream_status": "200" }
```
