.PHONY=default clean ros build

SPECS=stage1.spec stage2.spec stage3.spec

default: $(SPECS)

%.spec:
	@wget -q -O $@ "https://gitweb.gentoo.org/proj/releng.git/plain/releases/weekly/specs/amd64/$@"
	@echo "Downloading $@  ..."

clean: 
	rm $(SPECS)

# This has to be under %.spec because this one is built differently
stage4.spec: $(SPECS)
	@[ -f $@ ] || (echo "Copying stage3 -> stage4 ..." && cp stage3.spec $@ && sed -i 's/stage3/stage4/g; s/stage2/stage3/g' $@)

ros: stage4.spec
	@vim stage4.spec

build: stage4.spec
	@catalyst -f stage1.spec && catalyst -f stage2.spec && catalyst -f stage3.spec && catalyst -f stage4.spec
