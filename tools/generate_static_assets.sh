#!/bin/sh

#
#  generate 410, 404 and other static assets for a site
#

set -e

# "$site" "$domain" "$redirection_date" "$tna_timestamp" "$title" "$new_site"

site="$1"
domain="$2"
redirection_date="$3"
tna_timestamp="$4"
title="$5"
new_site="$6"

#
#  ensure static directory exists
#
path=dist/static/$site/
mkdir -p $path

#
#  generate 404 page
#
cat > "${path}/404.html" <<EOF
<!DOCTYPE html>
<html class="no-branding">
  <head>
    <meta charset="utf-8">
    <title>This page is missing</title>
    <link href="/gone.css" media="screen" rel="stylesheet" type="text/css">
  </head>
  <body>
    <section id="content" role="main" class="group">
      <div class="gone-container">
        <header class="page-header group">
          <div class="legacy-site-logo"></div>
          <hgroup>
            <h1>The $title website title has been replaced by GOV.UK</h1>
          </hgroup>
        </header>

        <article role="article" class="group">

          <p>On $redirection_date the $title website was replaced by <a href='$new_site'>$new_homepage</a>. <a href='https://www.gov.uk'>GOV.UK</a> is now the best place to find government services and information.</p>

          <p>A copy of the page you were looking for may be found in <a href='http://webarchive.nationalarchives.gov.uk/'>The UK Government Web Archive</a>.</p>

        </article>
      </div>
    </section>
  </body>
</html>
EOF


#
#  generate 410 page content
#
cat > "${path}/410.html" <<EOF
  <body>
    <section id="content" role="main" class="group">
      <div class="gone-container">
        <header class="page-header group">
          <div class="legacy-site-logo"></div>
          <hgroup>
            <h1>The $title website has been replaced</h1>
          </hgroup>
        </header>

        <article role="article" class="group">

          <p>On $redirection_date the $title website was replaced by <a href='$new_site'>gov.uk/$new_homepage</a>. <a href='https://www.gov.uk'>GOV.UK</a> is now the best place to find government services and information.</p>

          <p>GOV.UK does not cover every piece of content that used to be found on the $title website, and the page you are looking for is probably one of these.</p>

          <p>Essential government services and information can be found at <a href='https://www.gov.uk'>GOV.UK</a>.</p>

<?php
  \$archive_link = "http://webarchive.nationalarchives.gov.uk/$tna_timestamp/http://$domain" . \$_SERVER['REQUEST_URI'];

  if ( isset( \$archive_links[\$uri_without_slash] ) ) {
      \$archive_link = \$archive_links[\$uri_without_slash];
  }

  preg_match( "/dg_\d+/i", \$uri_without_slash, \$matches );
  if ( isset(\$matches[0]) ) {
      \$match = strtolower(\$matches[0]);
      if ( isset( \$archive_links[\$match] ) ) {
          \$archive_link = \$archive_links[\$match];
      }
  }
?>
          <p>A copy of the page you were looking for can be found in <a href="<?= \$archive_link ?>">The National Archives</a>, however it will not be updated after $redirection_date.</p>

<?php include '410_suggested_links.php'; ?>

        </article>
      </div>
    </section>
  </body>
</html>
EOF

#
#  robots.txt
#
cat > $path/robots.txt <<EOF
User-agent: *
Disallow:
Sitemap: http://$domain/sitemap.xml
EOF

#
#  assemble 410 php file
#
touch dist/${domain}.suggested_links.conf
touch dist/${domain}.archive_links.conf
cp redirector/410_suggested_links.php $path
cp redirector/favicon.ico $path
cp redirector/gone.css dist/static

cat \
    redirector/410_preamble.php \
    dist/${domain}.*suggested_links*.conf \
    dist/${domain}.archive_links.conf \
    redirector/410_header.php \
    $path/410.html \
    > $path/410.php


exit
