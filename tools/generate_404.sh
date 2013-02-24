#!/bin/sh

#
#  generate 404 page for a site
#
#  usage: tools/generate_404.sh "$site" "$host" "$redirection_date" "$tna_timestamp" "$title" "$furl" "$new_url"
#

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
#  generate 404 page
#
cat <<EOF
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

exit 0
