# Redirector

Nginx configuration and supporting tools and tests for the redirector, an Ngnix server used to redirect old websites being moved to GOV.UK.

## Sites

Each site is configured using a yaml file in the `data/transition-sites` directory:

Required:
* `whitehall_slug` — the slug used in Whitehall for the organisation which owns the site. Used for branding in Bouncer and access control in Transition.
* `site` — friendly name for the site
* `host` — primary hostname for site
* `tna_timestamp` — timestamp of the last good National Archives capture. eg 20131002172858
* `homepage` — URL for new site, used to redirect '/'. Must include the 'http' or 'https'.

Optional:
* `homepage_title` — site title for 404/410 pages. Defaults to organisation title. Should fit into the sentence: "Visit the new [title] site at [furl or homepage]"
* `extra_organisation_slugs` — additional organisations which own this site. Used for access control in Transition.
* `homepage_furl` — friendly URL displayed on 404/410 pages. Should redirect to the `homepage`. Doesn't need to include 'http' or 'https'.
* `aliases` — list of alias domains
* `global` — set a global redirect or archive for all paths
* `css` — a css class which determines the logo and brand colour used on 404/410 pages
* `options` — used to list significant querystrings for canonicalisation like this: `--query-string first:second:third`. A significant querystring is one which on the old website changes the content in a meaningful way - which we might therefore need to map to a different place.
* `global_redirect_append_path` — should the path the user supplied be appended
to the URL for the global redirect?
* `special_redirect_strategy` — when the transition is partial, some tools or content will be left behind and managed by the previous supplier. This setting can be one of:
    * `via_aka` - the supplier is redirecting some paths to our aka domain.
    * `supplier` - the supplier is managing redirects to gov.uk. No traffic comes through Bouncer for this site.

Use `rake new_site[abbr,whitehall_slug,host]` to create a new site with default
mappings and tests, with an option for which service to config e.g.

`rake new_site[ukba,uk-border-agency,www.ukba.homeoffice.gov.uk] SITE_TYPE=option`

where `option` is one of `redirector` or `bouncer` (bouncer as default)

You can also validate existing sites' whitehall_slugs by running

`rake whitehall:slug_check`

## Mappings

A CSV file in `data/mappings` for each site containing:

* `Old Url` — the Url to be redirected in canonical form
* `New Url` — the destination Url for a 301
* `Status` — 301 for a redirect, 410 for a page which is being deprecated
* `Suggested Link` — an optional suggested link for the 410 page
* `Archive Link` — an optional alternative link to The National Archives for the 410 page

During development, mappings are usually generated from spreadsheets, or using scripts.
Once live they are maintained in this repository.

`New Url` values may only contain a hostname cited in `data/whitelist.txt`.

## Server config

An nginx server block for each site in `redirector/configs`.

## Build

The build is through [GNU Make](http://www.gnu.org/software/make/), to build the site:

    $ ./jenkins.sh

## Dist

Nginx configuration is generated in `dist`.


## Assets

Directgov and Businesslink assets are stored in GitHub and deployed via s3,  see [assets-directgov](https://github.com/alphagov/assets-directgov) and [assets-businesslink](https://github.com/alphagov/assets-businesslink).

## Test

A list of the most important urls to be tested on each website in `data/tests/subsets/`.

You will need to install some Perl packages like this:
    sudo cpan Text::CSV
    sudo cpan YAML
    sudo cpan Crypt::SSLeay
    sudo cpan Mozilla::CA

### Test in a virtual

    export DEPLOY_TO=dev
    ./tools/smoke_tests.sh

### Test against preview

    export DEPLOY_TO=preview
    ./tools/smoke_tests.sh

### Test against production

    export DEPLOY_TO=production
    ./tools/smoke_tests.sh

## Akamai

The redirector is deployed behind Akamai. The domain should be added as a property to the Akamai redirector configuration before changing the DNS of websites being redirected.

