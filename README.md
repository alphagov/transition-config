Redirector
==========

Nginx configuration and supporting tools and tests for the redirector, an Ngnix server used to redirect old websites being moved to GOV.UK.

## Sites

A list of sites in data/sites.csv:

* `Site` — friendly name for the site
* `Domain` — primary domain for site
* `Redirection Date` — planned go live date
* `TNA Timestamp` — timestamp of the last good National Archives capture
* `Title` — site title for 410 page
* `New Site` — URL for 410 page
* `Mirrors` — space separated list of alias domains

## Mappings

A CSV file in `data/mappings` for each site containing:

* `Old Url` — the Url to be redirected in canonical form
* `New Url` — the destination Url for a 301
* `Status` — 301 for a redirect, 410 for a page which is being deprecated
* `Suggested Link` — an optional suggested link for the 410 page
* `Archive Link` — an alternative link to The National Archives for the 410 page

During development, mappings are usually generated from spreadsheets, or using scripts.
Once live they are maintained in this repository.

`New Url` values may only contain a hostname cited in `data/whitelist.txt`.

## Server config

An nginx server block for each site in `redirector/configs`.

## Build

    $ ./jenkins.sh

## Dist

Nginx configuration is generated in `dist`.


## Assets

Directgov and Businesslink assets are stored in GitHub and deployed via s3,  see [assets-directgov](https://github.com/alphagov/assets-directgov) and [assets-businesslink](https://github.com/alphagov/assets-businesslink).

## Test

A list of the most important urls to be tested on each website in `data/tests/subsets/`.

### Test in a virtual

    export DEPLOY_TO=dev
    ./smoke_tests.sh

### Test against preview

    export DEPLOY_TO=preview
    ./smoke_tests.sh

### Test against production

    export DEPLOY_TO=production
    ./full_tests.sh

## Akamai

The redirector is deployed behind Akamai. The domain should be added as a property to the Akamai redirector configuration before changing the DNS of websites being redirected.

# Process

## Current process of creating source csv files

The input data is a series of csv files for each department (latest takes precedence):

* Any other ??
* Analytics old -> nothing
* Sitemap old -> new
* Manual old -> new
* Furls old -> old
* Whitehall old -> new

We start with a blank set and patch each of these files on top of each other.

1. Sanitizes url:

* space encoding
* removing all spaces
* &amp; -> &
* removes extra close parentheses
* encodes commas

2. skips blanks or invalid old urls

* has to have a scheme and pass URI.parse

3. deduping

4. remaps

* admin urls -> public urls
* ensures that gov.uk urls use https
* if invalid new url, then 410s

5. folding
6. sort -u

## Possible command line chain

* fetch CSVs:
  * Any Other
  * Analytics
  * Sitemap
  * Manual mappings
  * Furls
  * Harvester
  * Whitehall
  * Patches
* concat together in from least reliable to most reliable (need fetch)
* sanitize (1 above) (split out from munge)
* skip blank or invalid old (split out from munge)
* tidy --overwrite (also c14n's) (Paul)
* admin -> public (split out from munge)
* govuk -> https (easy)
* 410 if invalid new (easy)
* fold (following redirects in the file) (split out from munge?)
* sort -u (easy)

## Current process for munging Scotland (very manual)

* munge, then remove all rows where the old url has a query string, then remove any that have mailto, then tidy

