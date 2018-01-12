# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
GNOME_ORG_MODULE="gobject-introspection"

inherit gnome.org
if [[ ${PV} = 9999 ]]; then
	GCONF_DEBUG="no"
	inherit gnome2-live
fi

DESCRIPTION="Build infrastructure for GObject Introspection"
HOMEPAGE="http://live.gnome.org/GObjectIntrospection/"

LICENSE="HPND"
SLOT="0"
if [[ ${PV} = 9999 ]]; then
	KEYWORDS=""
else
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
fi
IUSE=""

RDEPEND="!<${CATEGORY}/${PN/-common}-${PV}"
# Use !<${PV} because mixing gobject-introspection with different version of -common can cause issues like:
# http://forums.gentoo.org/viewtopic-p-7421930.html

src_configure() { :; }

src_compile() { :; }

src_install() {
	dodir /usr/share/aclocal
	insinto /usr/share/aclocal
	doins m4/introspection.m4

	dodir /usr/share/gobject-introspection-1.0
	insinto /usr/share/gobject-introspection-1.0
	doins Makefile.introspection
}
