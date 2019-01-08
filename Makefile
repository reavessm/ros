.PHONY=default clean ros build
THIS_FILE := $(lastword $(MAKEFILE_LIST))

SPECS=stage1.spec stage2.spec stage3.spec

default: $(SPECS)

%.spec:
	@wget -q -O $@ "https://gitweb.gentoo.org/proj/releng.git/plain/releases/weekly/specs/amd64/$@"
	@echo "Downloading $@ ..."

clean: 
	rm -f $(SPECS)

# This has to be under %.spec because this one is built differently
stage4.spec: $(SPECS)
	@[ -f $@ ] || (echo "Downloading $@ ..." && \
			wget -q https://raw.githubusercontent.com/gentoo/catalyst/master/examples/stage4_template.spec \
			-O $@)

ros: stage4.spec
	@vim stage4.spec

build: stage4.spec
	@catalyst -f stage1.spec && catalyst -f stage2.spec && catalyst -f stage3.spec && catalyst -f stage4.spec

update: 
	@echo NOTE: This will only update stages 1-3, not 4
	@$(MAKE) -f $(THIS_FILE) clean
	@$(MAKE) -f $(THIS_FILE) default
