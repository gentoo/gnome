# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit meson gnome.org

DESCRIPTION="GLib geocoding library that uses the Yahoo! Place Finder service"
HOMEPAGE="https://git.gnome.org/browse/geocode-glib"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="gtk-doc +introspection test"

RDEPEND="
	>=dev-libs/glib-2.44:2
	>=dev-libs/json-glib-0.99.2[introspection?]
	gnome-base/gvfs[http]
	>=net-libs/libsoup-2.42:2.4[introspection?]
	introspection? ( >=dev-libs/gobject-introspection-0.6.3:= )
"
DEPEND="${RDEPEND}
	>=sys-devel/gettext-0.19.6
	virtual/pkgconfig
	gtk-doc? ( dev-util/gtk-doc )
	test? ( sys-apps/dbus )
"

# FIXME: need network #424719, recheck
# need various locales to be present
RESTRICT="test"

src_configure() {
	local emesonargs=(
		$(meson_use test enable-installed-tests)
		$(meson_use introspection enable-introspection)
		$(meson_use gtk-doc enable-gtk-doc)
	)
	meson_src_configure
}

src_test() {
	export GVFS_DISABLE_FUSE=1
	export GIO_USE_VFS=gvfs
	ewarn "Tests require network access to http://where.yahooapis.com"
	dbus-launch meson_src_test || die "tests failed"
}
