server {
  server_name britishbusinessembassy.com;
  rewrite ^/(.*) http://www.britishbusinessembassy.com/$1 permanent;
}
