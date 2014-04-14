server {
  server_name ukti-gulf.com
  rewrite ^/(.*) http://www.ukti-gulf.com/$1 permanent;
}
