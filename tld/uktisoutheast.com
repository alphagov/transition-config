server {
  server_name uktisoutheast.com;
  rewrite ^/(.*) http://www.uktisoutheast.com/$1 permanent;
}
