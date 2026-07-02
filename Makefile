#!/bin/make -f
SHELL=/bin/sh

DC = docker compose
DC_RUN = $(DC) run --rm

DC_RUN_BLOG = $(DC_RUN) blog-cli
DC_RUN_MASTER_PASSWORD = $(DC_RUN) master-password-cli

dist: blog/compose.yml tools/master-password/compose.yml dist/blog dist/tools/master-password

### > BLOG

blog/node_modules: blog/package.json
	$(DC_RUN_BLOG) install

blog/dist: blog/node_modules
	$(DC_RUN_BLOG) run dist

blog/%:
	git submodule update --init --recursive blog

dist/blog: blog/dist
	mkdir -p $@
	cp -r blog/dist/* dist/blog

### < BLOG

### > MASTER PASSWORD

tools/master-password/node_modules: tools/master-password/package.json
	$(DC_RUN_MASTER_PASSWORD) install

tools/master-password/css/master-password.min.css: tools/master-password/node_modules tools/master-password/css/master-password.css
	$(DC_RUN_MASTER_PASSWORD) run build:css

tools/master-password/js/master-password.min.js: tools/master-password/node_modules tools/master-password/js/master-password.js
	$(DC_RUN_MASTER_PASSWORD) run build:js

tools/master-password/%:
	git submodule update --init --recursive tools/master-password

dist/tools/master-password: tools/master-password/index.html tools/master-password/css/master-password.min.css tools/master-password/js/master-password.min.js
	mkdir -p $@ $@/css $@/js
	cp tools/master-password/index.html $@
	cp tools/master-password/css/*.min.css $@/css/
	cp tools/master-password/js/*.min.js $@/js/

### < MASTER PASSWORD
