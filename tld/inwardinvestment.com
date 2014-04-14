server {
  server_name inwardinvestment.com;
  rewrite ^/(.*) http://www.inwardinvestment.com/$1 permanent;
}
