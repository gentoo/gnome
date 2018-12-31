# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit gnome2

DESCRIPTION="Actions, Menus and Toolbars Kit for GTK+ applications"
HOMEPAGE="https://gitlab.gnome.org/GNOME/amtk"

LICENSE="LGPL-2.1+"
SLOT="3"
KEYWORDS="~amd64 ~x86"
IUSE="+introspection test"

RDEPEND="
	>=dev-libs/glib-2.52:2
	>=x11-libs/gtk+-3.22
	introspection? ( >=dev-libs/gobject-introspection-1.42:= )
"
DEPEND="${DEPEND}
	test? ( dev-util/valgrind )
	>=sys-devel/gettext-0.19.4
	>=dev-util/gtk-doc-am-1.25
	virtual/pkgconfig
"

src_configure() {
	gnome2_src_configure \
		--disable-gtk-doc \
		$(use_enable introspection) \
		$(use_enable test valgrind)
}
