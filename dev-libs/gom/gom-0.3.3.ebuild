# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
GCONF_DEBUG="yes"
PYTHON_COMPAT=( python3_{4,5,6} )

inherit gnome-meson python-r1

DESCRIPTION="GObject to SQLite object mapper library"
HOMEPAGE="https://wiki.gnome.org/Projects/Gom"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="doc +introspection test"

RDEPEND="
	>=dev-db/sqlite-3.7:3
	>=dev-libs/glib-2.36:2
	introspection? ( >=dev-libs/gobject-introspection-1.30.0:= )
	${PYTHON_DEPS}
	>=dev-python/pygobject-3.16:3[${PYTHON_USEDEP}]
"
DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
	>=dev-util/intltool-0.40.0
	sys-devel/gettext
	virtual/pkgconfig
	test? ( x11-libs/gdk-pixbuf:2 )
"
# TODO: make gdk-pixbuf properly optional with USE=test

pkg_setup() {
	python_setup
}

src_prepare() {
	gnome-meson_src_prepare

	python_copy_sources
}

src_configure() {
	gnome-meson_src_configure \
		$(meson_use introspection enable-introspection) \
		$(meson_use doc enable-gtk-doc)

	python_foreach_impl run_in_build_dir \
		gnome-meson_src_configure \
			$(meson_use introspection enable-introspection) \
			$(meson_use doc enable-gtk-doc)

}

src_install() {
	gnome-meson_src_install


	docinto examples
	dodoc examples/*.py

	python_foreach_impl run_in_build_dir \
		meson_src_install DESTDIR="${D}" install-overridesPYTHON

}

src_test() {
	# tests may take a long time
	python_foreach_impl run_in_build_dir \
		meson_src_test
}
