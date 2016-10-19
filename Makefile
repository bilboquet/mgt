PREFIX ?= /usr

clean:
	-rm -f *~
	-rm -f bin/*~

install:
	cp bin/mgt bin/mgt-*.sh $PREFIX/bin

uninstall:
	rm $PREFIX/bin/mgt-*.sh $PREFIX/bin/mgt

