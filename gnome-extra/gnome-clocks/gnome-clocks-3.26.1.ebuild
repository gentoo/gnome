# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
VALA_MIN_API_VERSION="0.26"
inherit gnome-meson vala

DESCRIPTION="Clocks application for GNOME"
HOMEPAGE="https://wiki.gnome.org/Apps/Clocks"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	>=app-misc/geoclue-2.3.1:2.0
	>=dev-libs/glib-2.44:2
	>=dev-libs/libgweather-3.14:2=[vala]
	>=gnome-base/gnome-desktop-3.8:3=
	>=media-libs/gsound-0.98[vala]
	>=sci-geosciences/geocode-glib-1
	>=app-misc/geoclue-2.4
	>=x11-libs/gtk+-3.20:3
"
DEPEND="${RDEPEND}
	$(vala_depend)
	dev-util/itstool
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

src_prepare() {
	vala_src_prepare
	gnome-meson_src_prepare
}
