Redirector
==========

Nginx configuration and supporting tools and tests for the redirector, an Ngnix server used to redirect old websites being moved to GOV.UK.

## Adding a new website

### List the site

Add the site to data/sites.csv.

* `Site` — friendly name for the site
* `Domain` — primary domain for site
* `Redirection Date` — planned go live date
* `TNA Timestamp` — timestamp of the last good National Archives capture
* `Title` — site title for 410 page
* `New Site` — URL for 410 page
* `Mirrors` — space separated list of alias domains

### Create mappings

A CSV file in the data/mappings directory containing:

* `Old Url` — the http or https Url to be redirected
* `New Url` — the destination Url for a 301
* `Status` — 301 for a redirect, 410 for a page which is being deprecated
* `Suggested Link` — an optional suggested link for the 410 page
* `Archive Link` — an alternative link to The National Archives for the 410 page

During development, mappings are usually generated from spreadsheets, or using scripts.
Once live they are maintained in this repository.

### Create the Nginx server

Create an nginx server block for the site using one of the existing `redirector/configs` sites as a template.
Ensure any included dependencies exist.

### Build

    $ ./jenkins.sh

### Create a subset test

Create a list of the most important urls to be tested on each website in the `data/tests/subsets/` directory.

### Add to the full tests

Create a list of URLs to be tested in addition to those listed in the mappings and subsets in the `data/tests/full/` directory.

### Assets

Directgov and Businesslink assets are stored in GitHub and deployed via s3,  see [assets-directgov](https://github.com/alphagov/assets-directgov) and [assets-businesslink](https://github.com/alphagov/assets-businesslink).

### Test in a virtual

    export DEPLOY_TO=dev
    ./run_subset_integration_tests.sh

### Test against preview

    export DEPLOY_TO=preview
    ./run_subset_integration_tests.sh

### Test against production

    export DEPLOY_TO=production
    ./run_redirect_regression_tests.sh

### Akamai

The redirector is deployed behind Akamai. The domain should be added as a property to the Akamai redirector configuration before changing the DNS of websites being redirected.
