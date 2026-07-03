#!/bin/make -f
SHELL=/bin/sh

DC = docker compose
DC_RUN = $(DC) run --rm --user "$$(id -u):$$(id -g)" -e HOME=/tmp

DC_RUN_BLOG = $(DC_RUN) blog-cli
DC_RUN_MASTER_PASSWORD = $(DC_RUN) master-password-cli

dist: src/blog/compose.yml src/tools/master-password/compose.yml dist/blog dist/tools/master-password

### > BLOG

src/blog/node_modules: src/blog/package.json
	$(DC_RUN_BLOG) install

src/blog/dist: src/blog/node_modules
	$(DC_RUN_BLOG) run dist

src/blog:
	git submodule update --init --recursive --remote src/blog

src/blog/%:
	git submodule update --init --recursive src/blog

dist/blog: src/blog/dist
	mkdir -p $@
	cp -r src/blog/dist/* dist/blog

### < BLOG

### > MASTER PASSWORD

src/tools/master-password/node_modules: src/tools/master-password/package.json
	$(DC_RUN_MASTER_PASSWORD) install

src/tools/master-password/css/master-password.min.css: src/tools/master-password/node_modules src/tools/master-password/css/master-password.css
	$(DC_RUN_MASTER_PASSWORD) run build:css

src/tools/master-password/js/master-password.min.js: src/tools/master-password/node_modules src/tools/master-password/js/master-password.js
	$(DC_RUN_MASTER_PASSWORD) run build:js

src/tools/master-password:
	git submodule update --init --recursive --remote src/tools/master-password

src/tools/master-password/%:
	git submodule update --init --recursive src/tools/master-password

dist/tools/master-password: src/tools/master-password/index.html src/tools/master-password/css/master-password.min.css src/tools/master-password/js/master-password.min.js
	mkdir -p $@ $@/css $@/js
	cp src/tools/master-password/index.html $@
	cp src/tools/master-password/css/*.min.css $@/css/
	cp src/tools/master-password/js/*.min.js $@/js/

### < MASTER PASSWORD
