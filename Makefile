COFFEE=./node_modules/.bin/coffee

README.md: app.litcoffee
	cat $< | $(COFFEE) githubify.litcoffee > $@

serve:
	touch item.txt
	$(COFFEE) app.litcoffee

.PHONY: serve
