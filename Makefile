BASEDIR=$(CURDIR)
OUTPUTDIR=$(BASEDIR)/dist

GITHUB_REPO?=paulo-coutinho/iminerator-site

help:
	@echo 'Makefile for site options                                                 '
	@echo '                                                                          '
	@echo 'Usage:                                                                    '
	@echo '   make clean                          remove the generated files         '
	@echo '   make build                          regenerate dist files              '
	@echo '   make publish                        publish website on github          '
	@echo '   make setup                          install required things            '
	@echo '   make cloudflare-clear-cache         clear cloudflare cache             '
	@echo '   make git-upload                     push changes to git repository     '
	@echo '                                                                          '

clean:
	rm -rf $(OUTPUTDIR)

build:
	rm -rf dist
	npm run build
	cp src/site.webmanifest dist/
	cp src/images/favicon.ico dist/favicon.ico
	cp *.html dist/
	cp src/CNAME dist/
	cp src/app-ads.txt dist/
	find ./dist  -name '*.html' -type f -print0 | xargs -0 -n 1 sed -i '' -e 's/dist\//\//g'
	find ./dist  -name '*.css' -type f -print0 | xargs -0 -n 1 sed -i '' -e 's/dist\//\//g'

publish:
	make build
	mkdir -p $(OUTPUTDIR)
	@cd $(OUTPUTDIR) && \
	git init . && \
	git add . && \
	git commit -m "published new version"; \
	git push "git@github.com:$(GITHUB_REPO).git" master:gh-pages --force && \
	rm -rf .git
	make cloudflare-clear-cache

setup:
	npm install

cloudflare-clear-cache:
	curl -X DELETE \
      https://api.cloudflare.com/client/v4/zones/81ee2c4b8065ed7468a2938b3eff99b5/purge_cache \
      -H 'Authorization: Bearer ${PRS_CLOUDFLARE_TOKEN}' \
      -H 'Content-Type: application/json' \
      -d '{ "purge_everything": true }'

git-upload:
	git add --all && git commit -am "updated content" && git push origin master

.PHONY: clean build publish setup cloudflare-clear-cache git-upload
