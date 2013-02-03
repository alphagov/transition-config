Redirector
==========

Nginx configuration and supporting tools and tests for the redirector,
keeping our old websites on the internet, because [cool URIs don't change](http://www.w3.org/Provider/Style/URI.html).

Adding a new website
--------------------

### List the site

Add the site to data/sites.csv.

* Site: this is the name of the site, eg `communities` for the site `www.communities.gov.uk`
* Old homepage: e.g. http://www.communities.gov.uk
* New homepage: e.g. communities
* Redirection date: the date the site will be switched over for the 410 page
* National Archives timestamp: used in the link on the 410 page

Mappings may also be generated using scripts, e.g. businesslink\_piplinks and the lrc.

### Create mappings

A CSV file in the data/mappings directory containing:
* Old Url: the http or https Url to be redirected
* New Url: the destination Url for a 301
* Status: 301 for a redirect, 410 for a page which is being deprecated
* Suggested Links: an optional suggested link for the 410 page
* Archive Link: an alternative link to The National Archives for the 410 page

### Create the Nginx server

1. In the `redirector` directory, create nginx server blocks needed for the site using one of the existing sites as a template. Ensure any included dependencies exist.
2. Create the 404 and 410 pages.

    $ tools/generate_static_assets.sh
    $ generate_404_page $site $redirection_date $department_full_name $new_homepage
    $ generate_410_page $site $redirection_date $department_full_name $new_homepage $national_archives_timestamp $old_homepage

### Build

    $ ./jenkins.sh

### Create a Subset test

Create a list of the most important urls to be tested on each website in the `data/tests/subsets/` directory.

#### Create Regression test

Create a list of URLs to be tested in addition to those listed in the mappings and subsets in the `data/tests/full/` directory.

### Deploy the redirector to production

Deploy the redirector to production before altering puppet, note, there is no release tag -- all that is required for the production deploy is the build number of the latest Redirector job.

### Add the website to puppet

Add the new config file(s) to the `puppet` repository, in the file
`modules/govuk/manifests/apps/redirector.pp`:

    file { '/etc/nginx/sites-enabled/WEBSITE':
      ensure => link,
      target => '/var/apps/redirector/WEBSITE.conf',
      notify => Class['nginx::service'],
    }

Deploy puppet to preview to activate the website's configuration with nginx.

### Test against preview

    export DEPLOY_TO=preview
    ./run_subset_integration_tests.sh

### Test against production

    export DEPLOY_TO=production
    ./run_redirect_regression_tests.sh

Akamai
------

The redirector is deployed behind Akamai. The domain should be added as a property to the Akamai redirector configuration.

Assets
------

Directgov and Businesslink assets are stored in GitHub and deployed via s3,  see [assets-directgov](https://github.com/alphagov/assets-directgov) and [assets-businesslink](https://github.com/alphagov/assets-businesslink).
