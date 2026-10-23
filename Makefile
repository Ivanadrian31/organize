VERSION := 0.1.0
SHELL := /bin/bash
PKG := organize-dl_$(VERSION)_all
BUILD := build
DIST := dist
PKGDIR := $(BUILD)/$(PKG)

PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
MANDIR ?= $(PREFIX)/share/man/man1
COMPDIR ?= $(PREFIX)/share/bash-completion/completions

.PHONY: all check man versi deb lint uji-pasang install uninstall bersih

all: check

check:
	shellcheck --severity=style -x bin/organize-dl completions/organize-dl tests/helper.bash
	bats tests/*.bats

man:
	@! groff -man -Tutf8 -ww -z man/organize-dl.1 2>&1 >/dev/null | grep -q .

versi:
	@v_bin=$$(sed -n 's/^readonly VERSION="\(.*\)"$$/\1/p' bin/organize-dl); \
	v_ctl=$$(sed -n 's/^Version: //p' debian/control); \
	v_chg=$$(sed -n '1s/^organize-dl (\(.*\)).*/\1/p' debian/changelog); \
	if [ "$$v_bin" != "$(VERSION)" ] || [ "$$v_ctl" != "$(VERSION)" ] || [ "$$v_chg" != "$(VERSION)" ]; then \
	  echo "versi tidak sinkron: make=$(VERSION) bin=$$v_bin control=$$v_ctl changelog=$$v_chg" >&2; \
	  exit 1; \
	fi; \
	echo "versi $(VERSION) sinkron"

deb: check
	rm -rf "$(PKGDIR)"
	install -d "$(PKGDIR)/DEBIAN" "$(PKGDIR)/usr/bin" \
	  "$(PKGDIR)/usr/share/man/man1" \
	  "$(PKGDIR)/usr/share/bash-completion/completions" \
	  "$(PKGDIR)/usr/share/doc/organize-dl"
	install -m755 bin/organize-dl "$(PKGDIR)/usr/bin/organize-dl"
	install -m644 man/organize-dl.1 "$(PKGDIR)/usr/share/man/man1/organize-dl.1"
	gzip -9n "$(PKGDIR)/usr/share/man/man1/organize-dl.1"
	install -m644 completions/organize-dl \
	  "$(PKGDIR)/usr/share/bash-completion/completions/organize-dl"
	install -m644 debian/copyright "$(PKGDIR)/usr/share/doc/organize-dl/copyright"
	install -m644 debian/changelog "$(PKGDIR)/usr/share/doc/organize-dl/changelog"
	gzip -9n "$(PKGDIR)/usr/share/doc/organize-dl/changelog"
	install -m644 debian/control "$(PKGDIR)/DEBIAN/control"
	sed -i "s/^Installed-Size:.*/Installed-Size: $$(du -sk "$(PKGDIR)" | cut -f1)/" \
	  "$(PKGDIR)/DEBIAN/control"
	install -d "$(DIST)"
	dpkg-deb --build --root-owner-group "$(PKGDIR)" "$(DIST)/$(PKG).deb"

lint:
	lintian "$(DIST)"/*.deb

uji-pasang: deb
	bash tests/pasang-bersih.sh

install:
	install -d "$(DESTDIR)$(BINDIR)" "$(DESTDIR)$(MANDIR)" "$(DESTDIR)$(COMPDIR)"
	install -m755 bin/organize-dl "$(DESTDIR)$(BINDIR)/organize-dl"
	install -m644 man/organize-dl.1 "$(DESTDIR)$(MANDIR)/organize-dl.1"
	install -m644 completions/organize-dl "$(DESTDIR)$(COMPDIR)/organize-dl"

uninstall:
	rm -f "$(DESTDIR)$(BINDIR)/organize-dl" \
	  "$(DESTDIR)$(MANDIR)/organize-dl.1" \
	  "$(DESTDIR)$(COMPDIR)/organize-dl"

bersih:
	rm -rf "$(BUILD)" "$(DIST)"
