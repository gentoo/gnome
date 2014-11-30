# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
GCONF_DEBUG="no"

inherit gnome2

DESCRIPTION="GIO-based library for use by operating system components"
HOMEPAGE="https://wiki.gnome.org/Projects/LibGSystem"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+introspection +systemd"

RDEPEND="
	>=dev-libs/glib-2.34:2
	sys-apps/attr
	introspection? ( >=dev-libs/gobject-introspection-1.34 )
	systemd? ( >=sys-apps/systemd-200 )
"
DEPEND="${RDEPEND}
	>=dev-util/gtk-doc-am-1.15
	>=dev-libs/libxslt-1
	virtual/pkgconfig
"
