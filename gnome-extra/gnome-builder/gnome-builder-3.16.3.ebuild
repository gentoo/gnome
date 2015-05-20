# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
GCONF_DEBUG="no"

inherit gnome2

DESCRIPTION="Builder attempts to be an IDE for writing software for GNOME"
HOMEPAGE="https://wiki.gnome.org/Apps/Builder"

LICENSE="GPL-3+ GPL-2+ LGPL-3+ LGPL-2+ MIT CC-BY-SA CC0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+introspection"

RDEPEND="
	>=dev-libs/gjs-1.42
	>=dev-libs/glib-2.44:2
	>=dev-libs/libgit2-glib-0.22.6
	>=dev-libs/libxml2-2.9.0
	dev-python/pygobject:3
	>=dev-util/devhelp-3.16.0
	sys-devel/clang
	>=x11-libs/gtk+-3.16.1:3[introspection?]
	>=x11-libs/gtksourceview-3.16.1:3.0/3[introspection?]
"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.50.1
	>=sys-devel/gettext
	virtual/pkgconfig
"
src_configure() {
	gnome2_src_configure \
		$(use_enable introspection)
}
