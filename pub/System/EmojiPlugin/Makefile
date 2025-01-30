FOSWIKI_ROOT?=~/foswiki/core
SCRIPT_DIR=$(FOSWIKI_ROOT)/pub/System/EmojiPlugin
MAPPING_PM=$(FOSWIKI_ROOT)/lib/Foswiki/Plugins/EmojiPlugin/Mapping.pm
JSMIN=$(shell which terser 2>/dev/null || which uglifyjs) -m -c --
GZIP=gzip
CAT=cat

all: $(MAPPING_PM) emoji_pretty.json bundle.js.gz mapping.js.gz

.PHONY: all images clean mapping

images: img/google img/facebook img/apple img/twitter

clean: 
	rm -f $(TARGET) $(MAPPING_PM) mapping.uncompressed.js *gz

mapping: $(MAPPING_PM) mapping.uncompressed.js

node_modules:
	npm install 

mapping.uncompressed.js: aliases.json emoji_pretty.json tools/generate-mapping-js
	@echo "generating $@"; ./tools/generate-mapping-js > $@

bundle.uncompressed.js: emojis.uncompressed.js mapping.uncompressed.js 
	@echo "generating $@"; $(CAT) $^ > $@

%.js: %.uncompressed.js
	@echo minifying $@ from $<; $(JSMIN) $< > $@; \

%.gz: %
	@echo zipping $< to $@
	@$(GZIP) -9 -c $< > $@

$(MAPPING_PM): aliases.json emoji_pretty.json tools/generate-mapping-pm
	@echo "generating Mapping.pm"; ./tools/generate-mapping-pm > $@

ifneq (,$(wildcard node_modules))

img/apple: node_modules
	@echo "fetching apple images"; \
	test -d $@ || mkdir -p $@; \
	cp -a node_modules/emoji-datasource-apple/img/apple/64/* $@

img/facebook: node_modules
	@echo "fetching facebook images"; \
	test -d $@ || mkdir -p $@; \
	cp -a node_modules/emoji-datasource-facebook/img/facebook/64/* $@

img/google: node_modules
	@echo "fetching google images"; \
	test -d $@ || mkdir -p $@; \
	cp -a node_modules/emoji-datasource-google/img/google/64/* $@

img/twitter: node_modules
	@echo "fetching twitter images"; \
	test -d $@ || mkdir -p $@; \
	cp -a node_modules/emoji-datasource-twitter/img/twitter/64/* $@

emoji_pretty.json: node_modules node_modules/emoji-datasource-google/emoji_pretty.json
	@echo "fetching emoji definition"; \
	test -d $@ || mkdir -p $@; \
	cp node_modules/emoji-datasource-google/emoji_pretty.json $@

endif

