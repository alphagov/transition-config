#
#  Makefile to build the redirector
#

#
#  sources
#
mappingsdir=data/mappings
sites=data/sites.csv
whitelist=data/whitelist.txt
blacklist=data/blacklist.txt
SITES := $(wildcard data/sites/*.yml)

#
#  generated makefiles
#
VPATH=data/sites
MAKEFILES := $(patsubst data/sites/%.yml,makefiles/%.mk,$(SITES))

#
#  targets
#
configdir=dist/configs
commondir=dist/common
mapsdir=dist/maps
staticdir=dist/static
etcdir=dist/etc
validdir=tmp

#
#  commands
#
MUSTACHE=bundle exec mustache

.PHONY: init all ci dist config maps validate static etc

#
#  all
#
all:	validate dist
	@:

#
#  ci
#
ci:		test validate dist

#
#  dist
#
dist:	config maps static etc

#
#  test
#
test::
	prove -lj4 tests/lib/*.t

test::
	bundle install --deployment
	bundle exec rake test
	for t in tests/tools/*.sh ; do set -x ; $$t ; set +x ; done

test::
	prove -lj4 tests/unit/logic/*.t

#
#  validate
#
validate::	$(validdir) $(validdir)/sites.valid

$(validdir)/sites.valid:	$(validdir) $(sites) tools/validate_sites.pl
	rm -f $@
	prove tools/validate_sites.pl :: $(sites) && touch $@

$(validdir):;	mkdir -p $@

#
#  configs
#
$(configdir):;	mkdir -p $@

#
#  bespoke maps
#
maps::	dist/maps/lrc/lrc.conf dist/maps/businesslink/piplinks.conf

# lrc map
dist/maps/lrc/lrc.conf:	dist/maps/lrc data/lrc.csv tools/generate_lrc.pl
	tools/generate_lrc.pl data/lrc.csv > $@

# piplinks map
dist/maps/businesslink/piplinks.conf:	dist/maps/businesslink data/piplinks.csv tools/generate_piplinks.pl
	mkdir -p dist/maps/businesslink
	tools/generate_piplinks.pl data/piplinks.csv > $@

#
#  common config files
#
config::	dist/common/settings.conf dist/common/status_pages.conf

dist/common/settings.conf:	$(commondir) common/settings.conf
	cp common/settings.conf $@

dist/common/status_pages.conf:	$(commondir) common/status_pages.conf
	cp common/status_pages.conf $@

$(commondir):;	mkdir -p $@

#
#  static
#
static::	$(staticdir)/favicon.ico $(staticdir)/gone.css

$(staticdir)/favicon.ico:	static/favicon.ico $(staticdir)
	cp $< $@

$(staticdir)/gone.css:	static/gone.css $(staticdir)
	cp $< $@

$(staticdir):;	mkdir -p $@

#
#  etc
#
etc:: 	$(etcdir)/redirector.feature $(etcdir)/manifest

$(etcdir)/manifest:	tools/generate_manifest.sh 
	tools/generate_manifest.sh > $@

$(etcdir)/redirector.feature:	$(etcdir) $(sites) tools/generate_smokey_tests.sh
	tools/generate_smokey_tests.sh --sites $(sites) > $@

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
init::	makefiles $(MAKEFILES)

makefiles/%.mk:	%.yml
	$(MUSTACHE) $< templates/makefile.mustache > $@

$(MAKEFILES):	templates/makefile.mustache

makefiles:;	mkdir -p $@

prune::;	rm -rf makefiles

#
#  generate sites yml
#  - will become the canonical source, soon
#
data/sites:	$(sites)
	tools/explode_sites.sh
