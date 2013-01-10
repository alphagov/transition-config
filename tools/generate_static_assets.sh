#!/bin/sh

generate_404_page() {
	local name=$1
	local date_of_redirection=$2
    local department_name=$3
    local new_department_homepage=$4
    local path="$(pwd)/redirector/static/$name/"
	mkdir -p $path
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
            <h1>The website for the $department_name has been replaced by GOV.UK</h1>
          </hgroup>
        </header>

        <article role="article" class="group">

          <p>On $date_of_redirection the website for the $department_name was replaced by <a href='http://www.gov.uk/$new_department_homepage'>gov.uk/$new_department_homepage</a>, which is now the best place to find government services and information.</p>

        </article>
      </div>
    </section>
  </body>
</html>

EOF

}

generate_410_page(){
    local name=$1
    local date_of_redirection=$2
    local department_name=$3
    local new_department_homepage=$4
    local national_archives_timestamp=$5
    local old_website_address=$6
    local path="$(pwd)/redirector/static/$name/"
    mkdir -p $path #what happens if it's already there?
    cat > "${path}/410.html" <<EOF
  <body>
    <section id="content" role="main" class="group">
      <div class="gone-container">
        <header class="page-header group">
          <div class="legacy-site-logo"></div>
          <hgroup>
            <h1>The website for the $department_name has been replaced</h1>
          </hgroup>
        </header>

        <article role="article" class="group">

          <p>On $date_of_redirection the website for the $department_name was replaced by <a href='https://www.gov.uk/$new_department_homepage'>gov.uk/$new_department_homepage</a>.</p>

          <p>GOV.UK does not cover every piece of content that used to be found on the website for the $department_name. The page you are looking for is probably one of these.</p>

          <p>Essential government services and information can be found at <a href='https://www.gov.uk'>GOV.UK</a>.</p>

          <p>A copy of the page you were looking for can be found in <a href="http://webarchive.nationalarchives.gov.uk/$national_archives_timestamp/$old_website_address<?= $_SERVER['REQUEST_URI'] ?>">The UK Government Web Archive</a>, however it will not be updated after $date_of_redirection.</p>

<?php include '410_suggested_links.php'; ?>

        </article>
      </div>
    </section>
  </body>
</html>

EOF

}