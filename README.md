# Transition Config

This repository holds two things:

1. [`data/transition-sites`](data/transition-sites) - Configuration for sites being redirected to GOV.UK. This configuration is automatically loaded into the [Transition app](https://github.com/alphagov/transition)
2. [`tools/`](tools/) - Miscellaneous scripts for updating tna_timestamps, configuring root domain redirects and generating mappings.

## Adding a new site

### Prerequisites

Before you start, you need to know:

* the domain name being transitioned and any aliases
* the organisation that owns the site (and any additional organisations that should have access)
* the new homepage for the old site - often this is the organisation's page on GOV.UK, but sometimes it can be a different page on GOV.UK

### Create the site yaml file

Substitute each argument and then run the following rake task (you may need to run `bundle install` first):
```
  rake new_site[abbr,whitehall_slug,host]
```

for example:

```
  rake new_site["phe_chimat, public-health-england, www.chimat.org.uk"]
```

``abbr`` should be of the form:
```
  <owning_organisation_abbreviation>_<abbreviated_site_name>
```

Example for the "Obesity West Midlands" site which is owned by Public Health England:
```
  phe_obesitywm
```

The ``abbr`` is used in the URL for the site in the transition app. It is used as the primary key for a site and so shouldn't be changed once imported into the transition app, or a duplicate site will be created.

``whitehall_slug`` is the GOV.UK slug of the organisation that owns the site. This determines several things:

* where the site is found in the Transition app
* who has access to edit and create mappings for the site
* what organisation name and branding is used on pages served by Bouncer for URLs which aren't redirected

Extra organisations can be added later.

`host` will be one of the hostnames that the site has, for example:
```
  www.example.com
```

Aside: extra hostnames can be added later.

### Adding extra config to the site

The generated file only contains fields which are absolutely required.

Check that the `tna_timestamp` field is set. The rake task will try to find the latest archive by scraping the National Archives site, but this doesn't always work. You can find a list of the timestamps the National Archives have by going to their site, for example: [here are the timestamps for this Cabinet Office site](http://webarchive.nationalarchives.gov.uk/*/http://download.cabinetoffice.gov.uk>)

Some of the optional fields are frequently used:

* `aliases` - Almost every site will require aliases to cover the host name with/without `www.` (depending on which host was used in the ``host`` field)
* `options` - used to specify when a site's URLs have significant querystring parameters
* `extra_organisation_slugs` - used to enable members of other organisations to edit the mappings

See the [Site configuration](#site-configuration) for more details about these and other fields.

### Run the validation checks

These perform some cursory validations of the site configuration files.
```
  bundle exec rake validate:all
```

An option for a more thorough test of the config is to import it into the Transition app in development.

### Open a Pull Request

Commit the changes, push the branch and open a Pull Request.

### Import the site to Transition

Once merged, wait for the site to be imported into the Transition app. This currently happens automatically on the hour via a job on deploy.production and deploy.integration Jenkins' during working hours. It can also be triggered manually.

## Site configuration

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
* `options` — used to list significant querystrings for canonicalisation like this: `--query-string first:second:third`. A significant querystring parameter is one which on the old website changes the content in a meaningful way - which we might therefore need to map to a different place. **Query string parameters should be specified in lowercase; uppercase parameters will not be preserved during canonicalisation.**
* `global_redirect_append_path` — should the path the user supplied be appended
to the URL for the global redirect?
* `special_redirect_strategy` — when the transition is partial, some tools or content will be left behind and managed by the previous supplier. This setting can be one of:
    * `via_aka` - the supplier is redirecting some paths to our aka domain.
    * `supplier` - the supplier is managing redirects to gov.uk. No traffic comes through Bouncer for this site.

## Assets

We continue to serve some pages and assets for Directgov and BusinessLink sites. These are
stored in GitHub and served by Bouncer's nginx configuration. See:
* [assets-directgov](https://github.com/alphagov/assets-directgov)
* [assets-businesslink](https://github.com/alphagov/assets-businesslink)
* [Bouncer's nginx configuration](https://github.com/alphagov/govuk-puppet/blob/master/modules/govuk/manifests/apps/bouncer.pp#L28-L119)

Bouncer's nginx configuration also includes a small number of redirects and
other behaviours not possible with mappings.

## Glossary of terms

A glossary of the terms used can be found in this [blog post](https://insidegovuk.blog.gov.uk/2014/03/17/transition-technical-glossary/).
