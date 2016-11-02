PREFIX ?= /usr

clean:
	-rm -f *~
	-rm -f bin/*~
	-find . -name 'out' | xargs rm

install:
	cp bin/mgt bin/mgt-*.sh $PREFIX/bin

uninstall:
	rm $PREFIX/bin/mgt-*.sh $PREFIX/bin/mgt

.PHONY: tests
tests:
	cd tests && test_mgt.sh
