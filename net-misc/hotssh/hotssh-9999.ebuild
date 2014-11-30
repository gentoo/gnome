# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
GCONF_DEBUG="no"

inherit gnome2-live

DESCRIPTION="An interface to Secure Shell for Gnome and OpenSSH"
HOMEPAGE="https://wiki.gnome.org/Apps/HotSSH"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="
	>=dev-libs/glib-2.34:2
	>=x11-libs/gtk+-3.10:3
	x11-libs/vte:2.91
	dev-libs/libgsystem
	net-libs/libgssh:1
"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.50.1
	sys-devel/gettext
	virtual/pkgconfig
"
