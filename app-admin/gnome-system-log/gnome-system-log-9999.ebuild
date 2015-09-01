# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"
GCONF_DEBUG="no"

inherit gnome2
if [[ ${PV} = 9999 ]]; then
	inherit gnome2-live
fi

DESCRIPTION="System log viewer for GNOME"
HOMEPAGE="https://live.gnome.org/GnomeUtils"

LICENSE="GPL-2+ CC-BY-SA-3.0"
SLOT="0"
IUSE=""
if [[ ${PV} = 9999 ]]; then
	KEYWORDS=""
else
	KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux"
fi

COMMON_DEPEND="
	>=dev-libs/glib-2.31:2
	sys-libs/zlib:=
	>=x11-libs/gtk+-3.9.11:3
	x11-libs/pango
"
RDEPEND="${COMMON_DEPEND}
	gnome-base/gsettings-desktop-schemas
	!<gnome-extra/gnome-utils-3.4"
# ${PN} was part of gnome-utils before 3.4

DEPEND="${COMMON_DEPEND}
	>=dev-util/intltool-0.40
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
"

if [[ ${PV} = 9999 ]]; then
	DEPEND="${DEPEND}
		app-text/yelp-tools"
fi

src_configure() {
	gnome2_src_configure \
		--enable-zlib \
		ITSTOOL=$(type -P true)
}
