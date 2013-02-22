#!/bin/sh

#
#  generate 410, 404 and other static assets for a site
#
# tools/generate_static_assets.sh "$site" "$host" "$redirection_date" "$tna_timestamp" "$title" "$furl" "$new_url"

set -e

site="$1"
host="$2"
redirection_date="$3"
tna_timestamp="$4"
title="$5"
furl="$6"
new_url="$7"

homepage="www.gov.uk$furl"
archive_link="http://webarchive.nationalarchives.gov.uk/$tna_timestamp/http://$host"

#
#  ensure target directories exist
#
static=dist/static/$site
mkdir -p $static

lib=dist/static/$site
mkdir -p $lib

#
#  generate 404 page
#
cat > "$static/404.html" <<EOF
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
        <header class="page-header group $site">
          <div class="legacy-site-logo"></div>
          <hgroup>
            <h1>The $title website title has been replaced by GOV.UK</h1>
          </hgroup>
        </header>

        <article role="article" class="group">

          <p>On $redirection_date the $title website was replaced by <a href='$new_url'>$homepage</a>.</p>
          <p><a href='https://www.gov.uk'>GOV.UK</a> is now the best place to find essential government services and information.</p>
          <p>A copy of the page you were looking for may be found in <a href="$archive_link">The National Archives</a>.</p>

        </article>
      </div>
    </section>
  </body>
</html>
EOF

#  generate 418 page
#
cat > "$static/418.html" <<EOF
<!DOCTYPE html>
<html class="no-branding">
  <head>
    <meta charset="utf-8">
    <title>This page is awaiting content</title>
    <link href="/gone.css" media="screen" rel="stylesheet" type="text/css">
  </head>
  <body>
    <section id="content" role="main" class="group">
      <div class="gone-container">
        <header class="page-header group $site">
          <div class="legacy-site-logo"></div>
          <hgroup>
            <h1>This $title page is moving to GOV.UK but has not yet been published</h1>
          </hgroup>
        </header>

        <article role="article" class="group">

          <p>The $title website is being replaced by <a href='$new_url'>$homepage</a>.</p>
          <p><a href='https://www.gov.uk'>GOV.UK</a> is now the best place to find essential government services and information.</p>

        </article>
      </div>
    </section>
  </body>
</html>
EOF

#
#  generate 410 page content
#
cat > "$static/410.html" <<EOF
  <body>
    <section id="content" role="main" class="group">
      <div class="gone-container">
        <header class="page-header group $site">
          <div class="legacy-site-logo"></div>
          <hgroup>
            <h1>The $title website has been replaced</h1>
          </hgroup>
        </header>

        <article role="article" class="group">

          <p>On $redirection_date the $title website was replaced by <a href='$new_url'>$homepage</a>.</p>
          <p><a href='https://www.gov.uk'>GOV.UK</a> is now the best place to find essential government services and information.</p>

<?php
  \$archive_link = '$archive_link' . \$_SERVER['REQUEST_URI'];

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
          <p>A copy of the page you were looking for may be found in <a href="<?= \$archive_link ?>">The National Archives</a>, however it will not be updated after $redirection_date.</p>

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
cat > $static/robots.txt <<EOF
User-agent: *
Disallow:
Sitemap: http://$host/sitemap.xml
EOF

#
#  other static assets
#
cp redirector/favicon.ico $static
cp redirector/gone.css dist/static

#
#  assemble 410 php file
#
touch $lib/suggested_link.conf
touch $lib/archive_links.conf

cp redirector/410_suggested_links.php $static

cat redirector/410_preamble.php \
    $lib/*suggested_link*.conf \
    $lib/archive_links.conf \
    redirector/410_header.php \
    $static/410.html \
    > $static/410.php

exit
