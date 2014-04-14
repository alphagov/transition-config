server {
  server_name technologyworld.uk.com
  rewrite ^/(.*) http://www.technologyworld.uk.com/$1 permanent;
}
