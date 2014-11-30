# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
GCONF_DEBUG="no"

inherit gnome2

DESCRIPTION="GIO-like friendly API for libssh"
HOMEPAGE="https://wiki.gnome.org/Projects/LibGSSH"

LICENSE="LGPL-2+"
SLOT="1"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="
	>=dev-libs/glib-2.34:2
	dev-libs/libgsystem
	>=net-libs/libssh-0.6
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"
