COFFEE=./node_modules/.bin/coffee

README.md: server.litcoffee
	cat $< | $(COFFEE) githubify.litcoffee > $@

serve:
	touch item.txt
	$(COFFEE) server.litcoffee

reloader:
	NODE_ENV=development wachs --except item.txt make serve

# Ghetto tests
test:
	curl :3000/                  -s -D - | head -n 1
	curl :3000/app.css           -s -D - | head -n 1
	curl :3000/data.json         -s -D - | head -n 1
	curl :3000/default.appcache  -s -D - | head -n 1
	curl :3000/app.js            -s -D - | head -n 1

.PHONY: serve
