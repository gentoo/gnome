# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"
GCONF_DEBUG="yes"
CLUTTER_LA_PUNT="yes"

# inherit clutter after gnome2 so that defaults aren't overriden
inherit gnome2 clutter gnome.org
if [[ ${PV} = 9999 ]]; then
	inherit gnome2-live
fi

DESCRIPTION="Library for embedding a Clutter canvas (stage) in GTK+"
HOMEPAGE="https://wiki.gnome.org/Projects/Clutter"

SLOT="1.0"
IUSE="examples +introspection"
if [[ ${PV} = 9999 ]]; then
	KEYWORDS=""
	IUSE="${IUSE} doc"
else
	KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86"
fi

# XXX: Needs gtk with X support (!directfb)
RDEPEND="
	>=x11-libs/gtk+-3.6.0:3[introspection?]
	>=media-libs/clutter-1.18:1.0[introspection?]
	media-libs/cogl:1.0=[introspection?]
	introspection? ( >=dev-libs/gobject-introspection-0.9.12 )
"
DEPEND="${RDEPEND}
	dev-util/gtk-doc-am
	>=sys-devel/gettext-0.18
	virtual/pkgconfig
"

src_configure() {
	DOCS="NEWS README"
	EXAMPLES="examples/{*.c,redhand.png}"
	gnome2_src_configure \
		--disable-maintainer-flags \
		--enable-deprecated \
		$(use_enable introspection)
}
