server {
  server_name sceschools.com;
  rewrite ^/(.*) http://www.sceschools.com/$1 permanent;
}
