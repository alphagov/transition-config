#!/bin/sh

export PERL5LIB='lib'

perl tests/integration/count_all_sources.pl

perl tests_with_graphs.pl \
            tests/integration/ratified \
            'govuk.app.redirector.ratified'
