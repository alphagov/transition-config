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

Create a file `data/mappings/WEBSITE.csv` containing three columns:

* `Old Url` – the original URL
* `Status` – either 301 (when redirecting to a new page) or 410 (when the page has gone)
* `New Url` – optional when the `Status` is 410

It should be sorted on the Old Url column (this makes diffs between commits more readable).

### Create the site in the repository

1.  In the `redirector` directory, create a new configuration file containing
    the nginx server block(s) needed for the site.

1.  Add WEBSITE to `sites.sh`.

1.  Copy the static assets from `redirector/static/_skeleton` to
    `redirector/static/WEBSITE` and edit as necessary.
    
    *   `404.html` – add the date, department name and the new homepage (e.g. https://www.gov.uk/dclg)
    *   `410.html` – add the date, department name, new homepage, the National Archives timestamp and the old website address (this is for the National Archives link creation - for example, for DCLG the timestamp is 20120919132719 and the website is www.communities.gov.uk)
    *   `gone.css` - this does not require any change


### Create the required tests

#### Valid Lines

Add a valid lines test script: tests/logic/sources/WEBSITE_valid_lines.t, using one of the others as a template. This will be automated but is currently a manual step. It is required because jenkins.sh tests all the mappings before attempting to build. 

#### Subset test 

This is a quick test of the most important urls which will be run on every deployment.

It doesn't need to be 250, and it can just be a random sample, but ideally it would be the top 10% or so mappings in terms of importance.

1. Create a sample mappings file containing up to 250 urls, e.g. `tests/integration/test_data/top_250_WEBSITE_urls.csv`. 
2. Create the test script, e.g. `tests/integration/sample/top_250_WEBSITE.t` you can base it on `tests/integration/sample/top_250_directgov.t`

You can run this test using `prove -l tests/integration/sample/top_250_WEBSITE.t` but it will not pass until the redirector is deployed.

#### Complete test

This is a full integration test which is run on a nightly basis

Create test scripts at `tests/integration/ratified/WEBSITE/` you can base them on the tests in `tests/integration/ratified/directgov/`

### Dry-run the post-commit build

Run `bash jenkins.sh` before committing and pushing the new site to confirm
that it doesn't break, which would stop anyone from deploying.

The last line output by `jenkins.sh` is "Redirector build succeeded."

### Deploy the redirector to preview

A jenkins commit will kick off the Redirector build, followed by the Redirector-deploy (which only deploys to preview), 
then followed by the Redirector-Integration-Subset. 

You should make sure that these tests all pass before you deploy to production. 

### Deploy the redirector to production

You must deploy the redirector to production before altering puppet.

There is no release tag - all that is required for the production deploy is the build number of the latest Redirector job.

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

### When mappings are finalised

When all the mappings are complete, correct and passing the integration tests, you can make them finalised. 

This entails moving the site in sites.sh from IN_PROGRESS_SITES to REDIRECTED_SITES and creating the regression tests. Currently creating the regression test involves copying one of the ones in tests/redirects and renaming the site, but plans are afoot to automate at least that and tools/create_regression_tests.sh is the first step towards that.

Note that the tests in redirects/ are slightly different to the integration tests - the redirect tests call the method test_finalised_redirects rather than test_closed_redirects. This means that they do not fail if the 301 location is not a 200. Redirects to non-GOV.UK sites are tested for a successful response (i.e. 200, 301, 302 or 410) and redirects to GOV.UK are chased (max 3 redirects) to ensure they end up eventually at a 200 or 410.

This is so changing slugs that are handled correctly do not break the regression tests. Lists of chased redirects are output by the Jenkins job so these can easily be updated.
