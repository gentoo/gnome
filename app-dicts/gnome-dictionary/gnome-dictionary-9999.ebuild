# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"
GCONF_DEBUG="yes"

inherit gnome2
if [[ ${PV} = 9999 ]]; then
	inherit gnome2-live
fi

DESCRIPTION="Dictionary utility for GNOME"
HOMEPAGE="https://live.gnome.org/GnomeUtils"

LICENSE="GPL-2+ LGPL-2.1+ FDL-1.1+"
SLOT="0/8" # subslot = suffix of libgdict-1.0.so
IUSE="+introspection ipv6"
if [[ ${PV} = 9999 ]]; then
	IUSE="${IUSE} doc"
	KEYWORDS=""
else
	KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux"
fi

COMMON_DEPEND="
	>=dev-libs/glib-2.39:2
	x11-libs/cairo:=
	>=x11-libs/gtk+-3.14:3
	x11-libs/pango
	introspection? ( >=dev-libs/gobject-introspection-1.42 )
"
RDEPEND="${COMMON_DEPEND}
	gnome-base/gsettings-desktop-schemas
	!<gnome-extra/gnome-utils-3.4
"
# ${PN} was part of gnome-utils before 3.4
DEPEND="${COMMON_DEPEND}
	>=dev-util/gtk-doc-am-1.15
	>=dev-util/intltool-0.40
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
"

if [[ ${PV} = 9999 ]]; then
	DEPEND="${DEPEND}
		app-text/yelp-tools
		doc? ( >=dev-util/gtk-doc-1.15 )"
fi

src_configure() {
	local myconf=""
	[[ ${PV} != 9999 ]] && myconf="${myconf} ITSTOOL=$(type -P true)"
	gnome2_src_configure \
		$(use_enable introspection) \
		$(use_enable ipv6) \
		${myconf}
}
