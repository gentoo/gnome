# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python{3_4,3_5,3_6} )

inherit gnome.org gnome2-utils meson python-single-r1 xdg

DESCRIPTION="Music management for Gnome"
HOMEPAGE="https://wiki.gnome.org/Apps/Music"

LICENSE="GPL-2+"
SLOT="0"
IUSE=""
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

KEYWORDS="~amd64 ~x86"

COMMON_DEPEND="
	${PYTHON_DEPS}
	>=dev-libs/gobject-introspection-1.35.9:=
	>=x11-libs/gtk+-3.19.3:3[introspection]
	>=media-libs/libmediaart-1.9.1:2.0[introspection]
	>=app-misc/tracker-1.99.1[introspection(+)]
	>=dev-python/pygobject-3.21.1:3[cairo,${PYTHON_USEDEP}]
	>=media-libs/grilo-0.3.4:0.3[introspection]
"
# xdg-user-dirs-update needs to be there to create needed dirs
# https://bugzilla.gnome.org/show_bug.cgi?id=731613
RDEPEND="${COMMON_DEPEND}
	|| (
		app-misc/tracker-miners[gstreamer]
		app-misc/tracker-miners[ffmpeg]
	)
	x11-libs/libnotify[introspection]
	dev-python/requests[${PYTHON_USEDEP}]
	media-libs/gstreamer:1.0[introspection]
	media-libs/gst-plugins-base:1.0[introspection]
	media-plugins/gst-plugins-meta:1.0
	media-plugins/grilo-plugins:0.3[tracker]
	net-libs/gnome-online-accounts[introspection]
	x11-misc/xdg-user-dirs
"
DEPEND="${COMMON_DEPEND}
	dev-libs/libxml2:2
	dev-util/itstool
	>=sys-devel/gettext-0.19.7
	virtual/pkgconfig
"

# The only 2 tests are file validation tests, nothing to do with program behavior
RESTRICT="test"

src_prepare() {
	default
	sed -e '/sys.path.insert/d' -i "${S}"/gnome-music.in || die "python fixup sed failed"
}

src_install() {
	meson_src_install
	python_fix_shebang "${D}"usr/bin/gnome-music
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
	gnome2_icon_cache_update
}
