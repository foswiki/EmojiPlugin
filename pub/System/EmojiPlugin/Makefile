FOSWIKI_ROOT?=~/foswiki/core
SCRIPT_DIR=$(FOSWIKI_ROOT)/pub/System/EmojiPlugin/tools
MAPPING_PM=$(FOSWIKI_ROOT)/lib/Foswiki/Plugins/EmojiPlugin/Mapping.pm
JSMIN=$(shell which terser 2>/dev/null || which uglifyjs) -m -c --
CSSMIN=$(shell which csso 2>/dev/null || echo cat) --no-restructure
GZIP=gzip
CAT=cat
TARGET=$(MAPPING_PM) emoji_pretty.json build/pkg.js build/pkg.css build/mapping.js

all: $(TARGET) $(TARGET:.js=.js.gz) $(TARGET:.css=.css.gz) 

.PHONY: all images clean mapping

images: img/google img/facebook img/apple img/twitter

clean: 
	rm -f build/* $(MAPPING_PM) 

mapping: $(MAPPING_PM) build/mapping.uncompressed.js

node_modules:
	npm install 

build/mapping.uncompressed.js: aliases.json emoji_pretty.json tools/generate-mapping-js
	@echo "generating $@"; $(SCRIPT_DIR)/generate-mapping-js > $@

build/pkg.uncompressed.js: src/emojis.js build/mapping.uncompressed.js 
	@echo "generating $@"; $(CAT) $^ > $@

build/pkg.css: src/emojis.css
	@echo minifying $@ from $<; $(CSSMIN) $< > $@; \

build/%.js: build/%.uncompressed.js
	@echo minifying $@ from $<; $(JSMIN) $< > $@; \

build/%.css: build/%.uncompressed.css
	@echo minifying $@ from $<; $(CSSMIN) $< > $@; \

build/%.gz: build/%
	@echo zipping $< to $@
	@$(GZIP) -9 -c $< > $@

$(MAPPING_PM): aliases.json emoji_pretty.json tools/generate-mapping-pm
	@echo "generating Mapping.pm"; $(SCRIPT_DIR)/generate-mapping-pm > $@

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
	cp node_modules/emoji-datasource-google/emoji_pretty.json $@

endif

