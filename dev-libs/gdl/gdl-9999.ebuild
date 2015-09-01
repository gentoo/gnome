# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"
GCONF_DEBUG="no"

inherit gnome2
if [[ ${PV} = 9999 ]]; then
	inherit gnome2-live
fi

DESCRIPTION="GNOME docking library"
HOMEPAGE="https://developer.gnome.org/gdl/"

LICENSE="LGPL-2.1+"
SLOT="3/5" # subslot = libgdl-3 soname version
IUSE="+introspection"
if [[ ${PV} = 9999 ]]; then
	IUSE="${IUSE} doc"
	KEYWORDS=""
else
	KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
fi

RDEPEND="
	dev-libs/glib:2
	>=x11-libs/gtk+-3.0.0:3[introspection?]
	>=dev-libs/libxml2-2.4:2
	introspection? ( >=dev-libs/gobject-introspection-0.6.7 )
"
DEPEND="${RDEPEND}
	>=dev-util/gtk-doc-am-1.4
	>=dev-util/intltool-0.40.4
	virtual/pkgconfig
"

if [[ ${PV} = 9999 ]]; then
	DEPEND="${DEPEND}
		doc? ( >=dev-util/gtk-doc-1.4 )"
fi

src_configure() {
	DOCS="AUTHORS ChangeLog MAINTAINERS NEWS README"
	gnome2_src_configure $(use_enable introspection)
}
