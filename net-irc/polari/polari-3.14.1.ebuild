# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
GCONF_DEBUG="no"

inherit gnome2

DESCRIPTION="An IRC client for Gnome"
HOMEPAGE="https://wiki.gnome.org/Apps/Polari"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="
	dev-libs/gjs
	>=dev-libs/glib-2.41:2
	>=dev-libs/gobject-introspection-0.9.6
	net-libs/telepathy-glib[introspection]
	>=x11-libs/gtk+-3.13.4:3[introspection]
"
DEPEND="${RDEPEND}
	dev-util/appdata-tools
	>=dev-util/intltool-0.50
	virtual/pkgconfig
"
