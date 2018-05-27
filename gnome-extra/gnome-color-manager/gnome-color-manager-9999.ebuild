# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit git-r3 gnome-meson virtualx

DESCRIPTION="Color profile manager for the GNOME desktop"
HOMEPAGE="https://git.gnome.org/browse/gnome-color-manager"
SRC_URI=""
EGIT_MODULE="https://git.gnome.org/gnome-color-manager"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS=""
IUSE="packagekit raw test"

# Need gtk+-3.3.8 for https://bugzilla.gnome.org/show_bug.cgi?id=673331
# vte could be made optional
RDEPEND="
	>=dev-libs/glib-2.31.10:2
	>=media-libs/lcms-2.2:2
	>=media-libs/libcanberra-0.10[gtk3]
	media-libs/libexif
	media-libs/tiff:0=

	>=x11-libs/gtk+-3.3.8:3
	>=x11-libs/vte-0.25.1:2.91
	>=x11-misc/colord-1.3.1:0=
	>=x11-libs/colord-gtk-0.1.20

	packagekit? ( app-admin/packagekit-base )
	raw? ( media-gfx/exiv2:0= )
"
# docbook-sgml-{utils,dtd:4.1} needed to generate man pages
DEPEND="${RDEPEND}
	app-text/docbook-sgml-dtd:4.1
	app-text/docbook-sgml-utils
	dev-libs/appstream-glib
	dev-util/itstool
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

PATCHES=(
	# https://bugzilla.gnome.org/show_bug.cgi?id=796428
	"${FILESDIR}"/9999-remove-unwanted-check.patch
)

src_configure() {
	# Always enable tests since they are check_PROGRAMS anyway
	gnome-meson_src_configure \
		$(meson_use raw enable-exiv) \
		$(meson_use packagekit enable-packagekit) \
		$(meson_use test enable-tests)
}

src_test() {
	virtx meson_src_test
}

pkg_postinst() {
	gnome-meson_pkg_postinst

	if ! has_version media-gfx/argyllcms ; then
		elog "If you want to do display or scanner calibration, you will need to"
		elog "install media-gfx/argyllcms"
	fi
}
