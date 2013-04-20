all: dist

NETSURF ?= 3.0

PERL ?= perl
RM ?= rm -f

dist:
	$(PERL) prep-source-all.pl netsurf=$(NETSURF)

clean:
	$(RM) -r netsurf-full-$(NETSURF)*

distclean: clean
	$(RM) -r gits tars

riscos:
	$(RM) -r netsurf-riscos-build
	mkdir netsurf-riscos-build
	cd netsurf-riscos-build && wget http://ci.netsurf-browser.org/builds/sources/netsurf-full-$(NETSURF).tar.gz
	cd netsurf-riscos-build && tar -xzf netsurf-full-$(NETSURF).tar.gz
	cd netsurf-riscos-build/netsurf-full-$(NETSURF) && env NETSURF_USE_JS=YES NETSURF_USE_MOZJS=NO make TARGET=riscos
	cd netsurf-riscos-build/netsurf-full-$(NETSURF)/src/netsurf-$(NETSURF) && env NETSURF_USE_JS=YES NETSURF_USE_MOZJS=NO make TARGET=riscos package
	cp netsurf-riscos-build/netsurf-full-$(NETSURF)/src/netsurf-$(NETSURF)/netsurf.zip netsurf-riscos-$(NETSURF).zip

