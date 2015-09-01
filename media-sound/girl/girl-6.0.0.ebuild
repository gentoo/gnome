# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"
GCONF_DEBUG="no"

inherit gnome2

DESCRIPTION="Easily find and record live radio programs on the Internet"
HOMEPAGE="https://download.gnome.org/sources/girl"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="
	>=dev-libs/glib-2:2
	>=gnome-base/gnome-vfs-2:2
	>=gnome-base/libgnomeui-2
	>=x11-libs/gtk+-2.24:2
	dev-libs/libxml2:2
	media-video/totem
"
DEPEND="${RDEPEND}
	app-text/yelp-tools
	>=dev-util/gtk-doc-am-1.16
	>=dev-util/intltool-0.50.1
	virtual/pkgconfig
"

src_configure() {
	gnome2_src_configure --without-recording
}
