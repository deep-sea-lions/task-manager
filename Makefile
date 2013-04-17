COFFEE=./node_modules/.bin/coffee

README.md: server.litcoffee
	cat $< | $(COFFEE) githubify.litcoffee > $@

serve:
	touch item.txt
	$(COFFEE) server.litcoffee

reloader:
	NODE_ENV=development wachs --except item.txt make serve

PORT=3000

# Ghetto tests
test:
	# Basic GET requests
	curl :$(PORT)/                  -s -D - | head -n 1
	curl :$(PORT)/app.css           -s -D - | head -n 1
	curl :$(PORT)/data.json         -s -D - | head -n 1
	curl :$(PORT)/default.appcache  -s -D - | head -n 1

	# POST request
	curl :$(PORT)/ -d item=`head -c 3 /dev/random | xxd -l 3 -ps` -s -D - | head -n 1

	# JS build (slow)
	curl :$(PORT)/app.js            -s -D - | head -n 1

.PHONY: serve
