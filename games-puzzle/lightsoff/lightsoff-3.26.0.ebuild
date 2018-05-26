# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit gnome2 vala

DESCRIPTION="Turn off all the lights"
HOMEPAGE="https://wiki.gnome.org/Apps/Lightsoff"

LICENSE="GPL-2+ CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE=""

RDEPEND="
	>=dev-libs/glib-2.38:2
	>=gnome-base/librsvg-2.32:2
	>=media-libs/clutter-1.14:1.0
	>=media-libs/clutter-gtk-1.5.5:1.0
	>=x11-libs/gtk+-3.13.4:3
"
# libxml2+gdk-pixbuf required for glib-compile-resources
DEPEND="${RDEPEND}
	$(vala_depend)
	app-text/yelp-tools
	dev-libs/appstream-glib
	dev-libs/libxml2
	>=dev-util/intltool-0.50
	sys-devel/gettext
	virtual/pkgconfig
	x11-libs/gdk-pixbuf
"

src_prepare() {
	gnome2_src_prepare
	vala_src_prepare
}
