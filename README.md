Redirector
==========

Nginx configuration and supporting tools and tests for the redirector,
keeping our old websites on the internet, because [cool URIs don't change][cool].

[cool]:http://www.w3.org/Provider/Style/URI.html

Adding a new website
--------------------

### Initial steps

Add the site to data/sites.csv.

* Site: this is the name of the site, eg `communities` for the site `www.communities.gov.uk`
* Redirected: this will be N. When the mappings are correct and finalised, you will change this to Y.
* Old homepage: e.g. http://www.communities.gov.uk
* New homepage: e.g. communities (NB. Is this always the name? Can we then leave it out? Or, should we actually put, on the 410 pages, the new URL, e.g https://www.gov.uk/government/organisations/department-for-communities-and-local-government)
* Redirection date: the date the site will be switched over (this is for information on 410 pages)
* National Archives timestamp: this is required for the link on the 410 page

**NB** It is possible to generate mappings outside of this process, e.g. businesslink_piplinks, lrc. For help with making sure they are included, speak to a member of the Transition team

### Create the mappings CSV

    source tools/generate_configuration.sh
    generate_mappings_source $site $old_homepage $new_homepage

This creates a file in data/mappings with five columns - Old Url, Status (i.e. 301 or 410), New Url (if 301),Suggested Links (for 410 pages), Archive Link (e.g. for friendly URLs).

**NB** Old Url must be the first column. The others can appear in any order. Old Url and Status are mandatory and must have values. It is mandatory to have a New Url column but it may be empty (when Status is 410). The other columns are optional.

It also creates a redirect from the old department homepage to the new one.

This is the file that you should populate with your mappings. It should be sorted on the Old Url column (this makes diffs between commits more readable).

**NB** The Old Urls must start with the old homepage that you have set in sites.csv (it will accept http or https). So mod mappings must start with http://www.mod.uk or https://www.mod.uk. Any mappings that do not conform to this will generate a warning on build, be moved into a file called mod_incorrect.txt and must be handled manually.

### Create the site in the repository

1.  In the `redirector` directory, create a new configuration file containing
    the nginx server block(s) needed for the site (see below).
    **NB** You must create any files that you include, e.g. /var/apps/redirector/www.communities.gov.uk.location.conf - this can be empty, but if it doesn't exist, nginx will not be able to reload.

1. Create the 404 and 410 pages.

    source tools/generate_static_assets.sh

    generate_404_page $site $redirection_date $department_full_name $new_homepage

    generate_410_page $site $redirection_date $department_full_name $new_homepage $national_archives_timestamp $old_homepage

### Commit

Before committing, run `./jenkins.sh`. If this fails it will stop anyone else deploying so do not commit if so.

A jenkins commit will kick off the Redirector build, followed by the Redirector-deploy (which only deploys to preview), then followed by the Redirector-Integration-Subset.

You should make sure that these tests all pass before you deploy to production.

### Before You Finish

#### Create a Subset test

A pick list test of the most important urls to be tested on each deployment in the `data/subsets/` directory.

You can run these tests using `prove -l tests/integration/samples.t` but it will not pass until the redirector is deployed.

#### Create Regression test

You don't need this until the transition is complete but you might as well create it now.

    source tools/generate_tests.sh
    generate_regression_test $Name_of_site

$Name_of_site here should be with an initial capital, e.g. Directgov.


### Deploying the redirector to production

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
    prove -l tests/integration/in_progress/WEBSITE/

### Test against production

Once the tests pass in preview, deploy puppet and run the tests against
production.

    export DEPLOY_TO=production
    prove -l tests/integration/sample/top_250_WEBSITE.t
    prove -l tests/integration/in_progress/WEBSITE/

Once they pass, you can now proceed to switching the domains to the
redirector.

When mappings are finalised
---------------------------

When all the mappings are complete, correct and passing the integration tests, you can make them finalised.

This entails setting redirected to Y in sites.csv and creating the regression test (instructions above) if you haven't done so already.

The regression tests allow redirections to 301s, 302s and 410s as well as 200s. Redirects to GOV.UK are chased (max 3 redirects) to ensure they end up eventually at a 200 or 410. This is so changing slugs that are handled correctly do not break the regression tests. Lists of chased redirects are output by the Jenkins job so these can easily be updated.

Nginx configuration file
------------------------

Create an Nginx conf file for each domain, clone an existing simple configuration such as scotlandoffice.conf. 
Where source URLs containing a query\_string which is significant, a map using regular expressions will be needed
For an example of a map see the BusinessLink configuration.


Akamai
------

The redirector is deployed behind Akamai. The domain should be added as a property to the Akamai redirector configuration.

Assets
------

Directgov and Businesslink assets are stored in GitHub and deployed via s3,  see [assets-directgov](https://github.com/alphagov/assets-directgov) and [assets-businesslink](https://github.com/alphagov/assets-businesslink).
