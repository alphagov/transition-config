# Redirector

This repository holds three things:

1. [`data/transition-sites`](data/transition-sites) - Configuration for sites being redirected to GOV.UK. This configuration is automatically loaded into the [Transition app](https://github.com/alphagov/transition)
2. [`tld/`](tld/) - nginx configuration files which redirect from root domains, which cannot be pointed at our CDN, to subdomains which can be.
3. [`tools/`](tools/) - Miscellaneous scripts for updating tna_timstamps, configuring root domain redirects and generating mappings.

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

`rake new_site[ukba,uk-border-agency,www.ukba.homeoffice.gov.uk]`

## Assets

We continue to serve some pages and assets for Directgov and BusinessLink sites. These are
stored in GitHub and served by Bouncer's nginx configuration. See:
* [assets-directgov](https://github.com/alphagov/assets-directgov)
* [assets-businesslink](https://github.com/alphagov/assets-businesslink)
* [Bouncer's nginx configuration](https://github.gds/gds/puppet/blob/master/modules/govuk/manifests/apps/bouncer.pp#L28-L119)

Bouncer's nginx configuration also includes a small number of redirects and
other behaviours not possible with mappings.
