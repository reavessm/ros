.PHONY=default clean ros build cleanall
THIS_FILE := $(lastword $(MAKEFILE_LIST))

GENTOO_MIRROR="http://distfiles.gentoo.org/"
LATEST_STAGE3=${GENTOO_MIRROR}releases/amd64/autobuilds/$(shell curl --silent ${GENTOO_MIRROR}releases/amd64/autobuilds/latest-stage3-amd64.txt | awk 'END {print $$1}')
# make seed && make snapshot && make build

SPECS=stage1.spec stage2.spec stage3.spec

default: $(SPECS)

%.spec:
	@wget -q -O $@ "https://gitweb.gentoo.org/proj/releng.git/plain/releases/weekly/specs/amd64/$@" && sed -i 's/^portage_confdir.*$//g' $@
	@echo "Downloading $@ ..."

clean: 
	rm -f $(SPECS)

cleanall: clean
	rm -f snapshot seed

# This has to be under %.spec because this one is built differently
stage4.spec: $(SPECS)
	@[ -f $@ ] || (echo "Downloading $@ ..." && \
			wget -q https://raw.githubusercontent.com/gentoo/catalyst/master/examples/stage4_template.spec \
			-O $@)

ros: stage4.spec
	@vim stage4.spec

build: stage4.spec seed snapshot
	sudo sh -c "catalyst -f stage1.spec && sudo catalyst -f stage2.spec \
	&& sudo catalyst -f stage3.spec && sudo catalyst -f stage4.spec"

update: 
	@echo NOTE: This will only update stages 1-3, not 4
	@$(MAKE) -f $(THIS_FILE) clean
	@$(MAKE) -f $(THIS_FILE) default

snapshot:
	sudo sh -c "emerge --sync && layman -S && catalyst -s latest"
	touch snapshot

seed:
	sudo mkdir -p /var/tmp/catalyst/builds/default
	sudo wget $(LATEST_STAGE3) -O /var/tmp/catalyst/builds/default/stage3-amd64-latest.tar.xz
	touch seed
