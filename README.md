Redirector
==========

Nginx configuration and supporting tools and tests for the redirector,
keeping our old websites on the internet, because [cool URIs don't change][cool].

[cool]:http://www.w3.org/Provider/Style/URI.html


Adding a new website
--------------------

Add the site to sites.csv.

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

This creates a file in data/mappings with four columns - Old Url, Status (i.e. 301 or 410), New Url (if 301), Archive Link (e.g. for friendly URLs).

It also creates a redirect from the old department homepage to the new one.

This is the file that you should populate with your mappings. It should be sorted on the Old Url column (this makes diffs between commits more readable).

### Create the site in the repository

1.  In the `redirector` directory, create a new configuration file containing
    the nginx server block(s) needed for the site.

1. Create the 404 and 410 pages. 

    source tools/generate_static_assets.sh
    generate_404_page $department_name $redirection_date $department_full_name $new_department_homepage
    generate_410_page $department_name $redirection_date $department_full_name $new_department_homepage $national_archives_timestamp $old_website_address

### Create the required tests

#### Valid Lines

Add a valid lines test script:

    source tools/generate_tests.sh
    generate_valid_lines_test $Name_of_site

$Name_of_site here should be with an initial capital, e.g. Directgov.

This is required because jenkins.sh tests all the mappings before attempting to build. 

#### Subset test 

This is a quick test of the most important urls which will be run on every deployment.

It doesn't need to be 250, and it can just be a random sample, but ideally it would be the top 10% or so mappings in terms of importance.

1. Create a sample mappings file containing up to 250 urls, e.g. `tests/integration/test_data/top_250_WEBSITE_urls.csv`. 
2. Create the test script, e.g. `tests/integration/sample/top_250_WEBSITE.t` you can base it on `tests/integration/sample/top_250_directgov.t`

You can run this test using `prove -l tests/integration/sample/top_250_WEBSITE.t` but it will not pass until the redirector is deployed.

#### In Progress test

This is a full integration test which is run on a nightly basis

    source tools/generate_tests.sh
    generate_in_progress_gone_test Communities
    generate_in_progress_redirection_test Communities

#### Regression test

You don't need this until the transition is complete but you might as well create it now.

    source tools/generate_tests.sh
    generate_regression_test $Name_of_site

$Name_of_site here should be with an initial capital, e.g. Directgov.    

### Dry-run the post-commit build

Before committing, run `./jenkins.sh`. (If this fails it will stop anyone else deploying.)

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
