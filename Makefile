#
#  Makefile to build the redirector
#

#
#  sources
#
mappingsdir=data/mappings
sitesdir=data/sites
templatesdir=templates
whitelist=data/whitelist.txt
blacklist=data/blacklist.txt
sites := $(wildcard data/sites/*.yml)

#
#  generated makefiles
#
VPATH=data/sites
makefiles := $(patsubst data/sites/%.yml,makefiles/%.mk,$(sites))

#
#  targets
#
makedir=makefiles
configdir=dist/configs
commondir=dist/common
mapsdir=dist/maps
staticdir=dist/static
etcdir=dist/etc
libdir=dist/lib
validdir=tmp/valid
mappingsdist=dist/mappings

#
#  commands
#
ERB=./bin/erb.rb

.PHONY: makefiles all ci dist config maps validate static etc lib mappings

#
#  default
#
all:	test dist
	@:

#
#  ci
#
ci:		test validate dist

#
#  dist
#
dist:	mappings config maps static etc lib

#
#  test
#
test:	perl_test ruby_test sh_test php_test

perl_test::
	prove -lj4 tests/lib/c14n.t

php_test::
	tests/lib/url.php

ruby_test::
	bundle install --deployment
	bundle exec rake test whitehall:slug_check validate_hosts_unique

sh_test::
	for t in tests/tools/*.sh ; do set -e -x ; $$t ; set +x ; done

#
#  distributed mapping files
#
mappings::	\
	$(mappingsdist)/furls.csv

$(mappingsdist)/furls.csv:	$(sites) tools/generate_furls.sh
	@mkdir -p $(mappingsdist)
	tools/generate_furls.sh --sites $(sitesdir) > $@

#
#  bespoke maps
#
maps::	\
	dist/maps/businesslink_lrc/lrc.conf \
	dist/maps/businesslink/piplinks.conf

# lrc map
$(mapsdir)/businesslink_lrc/lrc.conf:	data/businesslink_lrc.csv tools/generate_lrc.pl
	@mkdir -p $(mapsdir)/businesslink_lrc
	tools/generate_lrc.pl data/businesslink_lrc.csv > $@

# piplinks map
$(mapsdir)/businesslink/piplinks.conf:	data/businesslink_piplinks.csv tools/generate_piplinks.pl
	@mkdir -p $(mapsdir)/businesslink
	tools/generate_piplinks.pl data/businesslink_piplinks.csv > $@

#
#  common config files
#
config::	\
	$(commondir)/settings.conf \
	$(commondir)/status_pages.conf

$(commondir)/settings.conf:	common/settings.conf
	@mkdir -p $(commondir)
	cp common/settings.conf $@

$(commondir)/status_pages.conf:	common/status_pages.conf
	@mkdir -p $(commondir)
	cp common/status_pages.conf $@

#
#  static
#
static::	\
	$(staticdir)/favicon.ico \
	$(staticdir)/gone.css \
	$(staticdir)/ie.css \
	$(staticdir)/businesslink-logo-2x.png \
	$(staticdir)/directgov-logo-2x.png \
	$(staticdir)/bis_crest_13px_x2.png \
	$(staticdir)/bis_crest_18px_x2.png \
	$(staticdir)/govuk-crest.png \
	$(staticdir)/govuk-logo.gif \
	$(staticdir)/govuk-logo.png \
	$(staticdir)/ho_crest_13px_x2.png \
	$(staticdir)/ho_crest_18px_x2.png \
	$(staticdir)/mod_crest_13px_x2.png \
	$(staticdir)/mod_crest_18px_x2.png \
	$(staticdir)/org_crest_13px_x2.png \
	$(staticdir)/org_crest_18px_x2.png \
	$(staticdir)/so_crest_13px_x2.png \
	$(staticdir)/so_crest_18px_x2.png \
	$(staticdir)/wales_crest_13px_x2.png \
	$(staticdir)/wales_crest_18px_x2.png \

$(staticdir)/favicon.ico:	static/favicon.ico
	@mkdir -p $(staticdir)
	cp $< $@

$(staticdir)/gone.css:	static/gone.css
	@mkdir -p $(staticdir)
	cp $< $@

$(staticdir)/ie.css:	static/ie.css
	@mkdir -p $(staticdir)
	cp $< $@

$(staticdir)/businesslink-logo-2x.png:	static/businesslink-logo-2x.png
	@mkdir -p $(staticdir)
	cp $< $@

$(staticdir)/directgov-logo-2x.png:	static/directgov-logo-2x.png
	@mkdir -p $(staticdir)
	cp $< $@

$(staticdir)/bis_crest_13px_x2.png:	static/bis_crest_13px_x2.png
	@mkdir -p $(staticdir)
	cp $< $@

$(staticdir)/bis_crest_18px_x2.png:	static/bis_crest_18px_x2.png
	@mkdir -p $(staticdir)
	cp $< $@

$(staticdir)/govuk-crest.png:	static/govuk-crest.png
	@mkdir -p $(staticdir)
	cp $< $@

$(staticdir)/govuk-logo.gif:	static/govuk-logo.gif
	@mkdir -p $(staticdir)
	cp $< $@

$(staticdir)/govuk-logo.png:	static/govuk-logo.png
	@mkdir -p $(staticdir)
	cp $< $@

$(staticdir)/ho_crest_13px_x2.png:	static/ho_crest_13px_x2.png
	@mkdir -p $(staticdir)
	cp $< $@

$(staticdir)/ho_crest_18px_x2.png:	static/ho_crest_18px_x2.png
	@mkdir -p $(staticdir)
	cp $< $@

$(staticdir)/mod_crest_13px_x2.png:	static/mod_crest_13px_x2.png
	@mkdir -p $(staticdir)
	cp $< $@

$(staticdir)/mod_crest_18px_x2.png:	static/mod_crest_18px_x2.png
	@mkdir -p $(staticdir)
	cp $< $@

$(staticdir)/org_crest_13px_x2.png:	static/org_crest_13px_x2.png
	@mkdir -p $(staticdir)
	cp $< $@

$(staticdir)/org_crest_18px_x2.png:	static/org_crest_18px_x2.png
	@mkdir -p $(staticdir)
	cp $< $@

$(staticdir)/so_crest_13px_x2.png:	static/so_crest_13px_x2.png
	@mkdir -p $(staticdir)
	cp $< $@

$(staticdir)/so_crest_18px_x2.png:	static/so_crest_18px_x2.png
	@mkdir -p $(staticdir)
	cp $< $@

$(staticdir)/wales_crest_13px_x2.png:	static/wales_crest_13px_x2.png
	@mkdir -p $(staticdir)
	cp $< $@

$(staticdir)/wales_crest_18px_x2.png:	static/wales_crest_18px_x2.png
	@mkdir -p $(staticdir)
	cp $< $@

#
#  etc
#
etc:: 	\
	$(etcdir)/manifest \
	$(etcdir)/redirector.feature \
	$(etcdir)/routes.txt \
	$(etcdir)/totals.csv

$(etcdir)/manifest:	templates/manifest.erb
	@mkdir -p $(etcdir)
	$(ERB) templates/manifest.erb > $@

$(etcdir)/redirector.feature:	$(sites) tools/generate_smokey_tests.sh
	@mkdir -p $(etcdir)
	tools/generate_smokey_tests.sh --sites $(sitesdir) > $@

$(etcdir)/routes.txt:	$(sites) tools/generate_routes.sh
	@mkdir -p $(etcdir)
	tools/generate_routes.sh --sites $(sitesdir) > $@

$(etcdir)/totals.csv:	$(mappings) tools/count_mappings.sh
	@mkdir -p $(etcdir)
	tools/count_mappings.sh --dir $(mappingsdir) > $@

$(etcdir):;	mkdir -p $@

#
#  lib
#
etc:: 	\
	$(libdir)/url.php

$(libdir)/url.php:	lib/url.php
	@mkdir -p $(libdir)
	cp $< $@

#
#  clean
#
clean::	clobber
	rm -rf $(validdir)/sites.valid dist

#
#  clobber
#
clobber::

#
#  include generated makefiles
#
-include makefiles/*.mk

#
#  bootstrap
#  - should be run as a separate make
#
makefiles:	$(makefiles)

$(makedir)/%.mk:	%.yml
	@mkdir -p $(makedir)
	$(ERB) -y $< $(templatesdir)/makefile.erb > $@

$(makefiles):	$(templatesdir)/makefile.erb

clean::;	rm -rf $(makedir)
