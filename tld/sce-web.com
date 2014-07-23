server {
  server_name sce-web.com;
  rewrite ^/(.*) http://www.sce-web.com/$1 permanent;
}
