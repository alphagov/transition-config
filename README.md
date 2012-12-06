Redirector
==========

Nginx configuration and supporting tools and tests for the redirector,
keeping our old websites on the internet, because [cool URIs don't change][cool].

[cool]:http://www.w3.org/Provider/Style/URI.html


Adding a new website
--------------------

**n.b.** during these instructions WEBSITE should be replaced with the name of
the site being added (eg 'communities' for the site `www.communities.gov.uk`).

### Create the mappings CSV

Create a file `data/<WEBSITE>_mappings_source.csv` containing three columns:

* `Old Url` – the original URL
* `Status` – either 301 (when redirecting to a new page) or 410 (when the page has gone)
* `New Url` – optional when the `Status` is 410

It should be sorted on the Old Url column (this makes diffs between commits more readable).

Optionally, create a sample to be used for integration testing at `tests/integration/test_data/top_250_WEBSITE_urls.csv`. We recommend that this should contain the most important urls on the site. If you don't provide this sample, a random 250 entries will be taken from the full file.

### Create the site in the repository

1.  In the `redirector` directory, create a new configuration file containing
    the nginx server block(s) needed for the site.

1.  Add WEBSITE to `sites.sh`.

1.  Copy the static assets from `redirector/static/_skeleton` to
    `redirector/static/WEBSITE` and edit as necessary.
    
    *   `404.html` – add the department name
    *   `410.html` – add the department name and the timestamp in the link
        to the National Archives for the correct crawl
    *   `gone.css`


### Create the required tests

1.  Create the test file for the top 250 URLs data source. This is done by
    copying an existing test `tests/integration/sample/top_250_directgov.t`
    and amending any references to directgov to the new website.

2.  Create the test files for the complete mappings source. This is done by
    copying the two test files under `tests/integration/ratified/directgov/`
    to a new directory and amending any references to directgov to the new
    website.

### Dry-run the post-commit build

Run `bash jenkins.sh` before committing and pushing the new site to confirm
that it doesn't break, which would stop anyone from deploying.

The last line output by `jenkins.sh` is "Redirector build succeeded."

### Deploy the redirector

At this point, the redirector repository will need to be deployed to 
preview and production. This ensures the new configuration files are
available before altering the puppetry.

### Add the website to puppet

Add the new config file(s) to the `puppet` repository, in the file
`modules/govuk/manifests/apps/redirector.pp`:

    file { '/etc/nginx/sites-enabled/WEBSITE':
      ensure => link,
      target => '/var/apps/redirector/WEBSITE.conf',
      notify => Class['nginx::service'],
    }

### Test against preview

Deploy puppet to preview to activate the website's configuration with nginx.

Run the subset and full integration tests against preview to confirm that
all links are actually being redirected.

    export DEPLOY_TO=preview
    prove -l tests/integration/sample/top_250_WEBSITE.t
    prove -l tests/integration/ratified/WEBSITE/

### Test against production

Once the tests pass in preview, deploy puppet and run the tests against
production.

    export DEPLOY_TO=production
    prove -l tests/integration/sample/top_250_WEBSITE.t
    prove -l tests/integration/ratified/WEBSITE/

Once they pass, you can now proceed to switching the domains to the 
redirector.
