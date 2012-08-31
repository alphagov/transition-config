redirector
==========

This needs tidying up, but currently, the Makefile downloads the Directgov mappings from the Migratorator and the Business Link mappings from Ben's spreadsheet in GoogleDocs. It then creates two CSVs with the three columns that are required for the tests and nginx config: Old Url, New Url and HTTP Status Code (i.e. 301/410).

The two integration tests fail - the Business Link one because there is no config in nginx and the Directgov one because there are 301s that have no New URL. It also does not test 410s.

So - WIP. 