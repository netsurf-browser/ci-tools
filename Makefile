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
	cd netsurf-riscos-build/netsurf-full-$(NETSURF)/src/libnsfb-* && $(RM) Makefile && echo "%:" > Makefile && echo "	true" >> Makefile
	cd netsurf-riscos-build/netsurf-full-$(NETSURF) && perl -pi -e's@^(NSLIBTARG :=.*)$$@$$1 src/librufl-0.0.2 src/libpencil-0.0.2@' Makefile
	cd netsurf-riscos-build/netsurf-full-$(NETSURF) && env NETSURF_USE_JS=YES NETSURF_USE_MOZJS=NO make TARGET=riscos
	cd netsurf-riscos-build/netsurf-full-$(NETSURF)/src/netsurf-$(NETSURF) && env NETSURF_USE_JS=YES NETSURF_USE_MOZJS=NO PKG_CONFIG_PATH=$(shell pwd)/netsurf-riscos-build/netsurf-full-$(NETSURF)/prefix-riscos/lib/pkgconfig make TARGET=riscos PREFIX=$(shell pwd)/netsurf-riscos-build/netsurf-full-$(NETSURF)/prefix-riscos package
	cp netsurf-riscos-build/netsurf-full-$(NETSURF)/src/netsurf-$(NETSURF)/netsurf.zip netsurf-riscos-$(NETSURF).zip

