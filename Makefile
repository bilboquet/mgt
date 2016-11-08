PREFIX ?= /usr

clean:
	-rm -f *~
	-rm -f bin/*~
	-find . -name 'out' -o -name 'input' -o -name 'interactive' -o -name 'exp_res' -o -name 'pretty_name'| xargs rm

install:
	cp bin/mgt bin/mgt-*.sh $(PREFIX)/bin
	mkdir -p /usr/share/mgt
	cp share/mgt-completion.sh $(PREFIX)/share/mgt

uninstall:
	rm $(PREFIX)/bin/mgt-*.sh $(PREFIX)/bin/mgt
	rm -rf $(PREFIX)/share/mgt

.PHONY: tests
tests:
	cd tests && ./test_mgt.sh $(LIST)
