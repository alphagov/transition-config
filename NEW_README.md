Adding a new site






Sites in progress




Once your redirection is complete, your mappings no longer require updating, and the integration tests pass (as much as they are going to[1]), move the site name from IN_PROGRESS_SITES to REDIRECTED_SITES - and here's why...


Sites redirected

There are three differences with sites that have already been redirected.

1. The configuration is not generated anew each build. If this is required, e.g. new mappings are required, put the site name back into IN_PROGRESS_SITES in sites.sh and the configuration will be regenerated on next deploy.

2. The input, since it has not changed is assumed to be valid and is not retested.

3. The tests check that the new URL, if GOV.UK, is a valid response, i.e. 200, 301, 302 or 410. As long as slugs are redirected when changed on GOV.UK we don't need to fail the tests, but we might want to know about that while producing mappings. 


[1] Why might the mappings not run the full test