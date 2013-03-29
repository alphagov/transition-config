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
validdir=tmp/valid
mappingsdist=dist/mappings

#
#  commands
#
ERB=./bin/erb.rb

.PHONY: makefiles all ci dist config maps validate static etc mappings

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
dist:	mappings config maps static etc

#
#  test
#
test::
	prove -lj4 tests/lib/*.t

test::
	bundle install --deployment
	bundle exec rake test
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
#  additional config files
#
config::	\
	$(configdir)/businesslink_events.conf \
	$(configdir)/businesslink_events_admin.conf \
	$(configdir)/businesslink_tariff.conf \
	$(configdir)/directgov_campaigns.conf \
	$(configdir)/directgov_jobseekers.conf \
	$(configdir)/directgov_subdomains.conf \
	$(configdir)/dfid_consultation.conf

$(configdir)/businesslink_events.conf:	configs/businesslink_events.conf
	@mkdir -p $(configdir)
	cp $< $@

$(configdir)/businesslink_events_admin.conf:	configs/businesslink_events_admin.conf
	@mkdir -p $(configdir)
	cp $< $@

$(configdir)/businesslink_tariff.conf:	configs/businesslink_tariff.conf
	@mkdir -p $(configdir)
	cp $< $@

$(configdir)/directgov_campaigns.conf:	configs/directgov_campaigns.conf
	@mkdir -p $(configdir)
	cp $< $@

$(configdir)/directgov_jobseekers.conf:	configs/directgov_jobseekers.conf
	@mkdir -p $(configdir)
	cp $< $@

$(configdir)/directgov_subdomains.conf:	configs/directgov_subdomains.conf
	@mkdir -p $(configdir)
	cp $< $@

$(configdir)/dfid_consultation.conf:	configs/dfid_consultation.conf
	@mkdir -p $(configdir)
	cp $< $@


#
#  static
#
static::	\
	$(staticdir)/favicon.ico \
	$(staticdir)/gone.css

$(staticdir)/favicon.ico:	static/favicon.ico
	@mkdir -p $(staticdir)
	cp $< $@

$(staticdir)/gone.css:	static/gone.css
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
