COFFEE=./node_modules/.bin/coffee

README.md: app.litcoffee
	cat $< | $(COFFEE) githubify.litcoffee > $@

serve:
	$(COFFEE) app.litcoffee

.PHONY: serve
