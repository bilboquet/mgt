PREFIX ?= /usr

clean:
	-rm -f *~
	-rm -f bin/*~
	-find . -name 'out' -o -name 'input' -o -name 'interactive' -o -name 'exp_res'| xargs rm

install:
	cp bin/mgt bin/mgt-*.sh $PREFIX/bin

uninstall:
	rm $PREFIX/bin/mgt-*.sh $PREFIX/bin/mgt

.PHONY: tests
tests:
	cd tests && ./test_mgt.sh
