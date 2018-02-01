# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit gnome-meson vala

DESCRIPTION="Leverage the power of HTTPS Everywhere"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc"
#FIXME does vala_depend go here?
RDEPEND="
	dev-libs/glib:2
	dev-libs/json-glib
	>=net-libs/libsoup-2.4
	dev-libs/libgee:0.8
	app-arch/libarchive
	$(vala_depend)
"
DEPEND="${RDEPEND}
	>=dev-util/meson-0.39.1
"

src_prepare() {
	vala_src_prepare
	gnome-meson_src_prepare
	default
}

#FIXME enable valadoc
src_configure() {
	gnome-meson_src_configure -Denable_valadoc=false
}
