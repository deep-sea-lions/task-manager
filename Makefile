COFFEE=./node_modules/.bin/coffee

README.md: server.litcoffee
	cat $< | $(COFFEE) githubify.litcoffee > $@

serve:
	touch item.txt
	$(COFFEE) server.litcoffee

reloader:
	NODE_ENV=development wachs --except item.txt make serve

.PHONY: serve
