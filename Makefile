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
