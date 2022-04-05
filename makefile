#
# This file compiles the project and places the program into a place
# where Terminal can access it. We make the directories if they
# don't exist yet.
#

prefix := /usr/local
install:
	test -d $(prefix) || mkdir $(prefix)
	test -d $(prefix)/bin || mkdir $(prefix)/bin
	swift package clean
	swift build --configuration release
	install .build/release/iosrssi $(prefix)/bin/iosrssi

clean:
	rm -f $(prefix)/bin/iosrssi
