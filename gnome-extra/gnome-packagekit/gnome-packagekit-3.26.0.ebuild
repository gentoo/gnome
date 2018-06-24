# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit gnome-meson virtualx

DESCRIPTION="PackageKit client for the GNOME desktop"
HOMEPAGE="https://www.freedesktop.org/software/PackageKit/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="systemd test"

RDEPEND="
	>=dev-libs/glib-2.32:2
	>=x11-libs/gtk+-3.15.3:3
	>=app-admin/packagekit-base-0.9.1
	systemd? (
		sys-auth/polkit
		>=sys-apps/systemd-42 )
"
DEPEND="${RDEPEND}
	app-text/docbook-sgml-utils
	dev-libs/appstream-glib
	dev-libs/libxml2:2
	>=sys-devel/gettext-0.19.7
	virtual/pkgconfig
"

# NOTES:
# app-text/docbook-sgml-utils required for man pages
# libxml2 required for glib-compile-resources

# UPSTREAM:
# see if tests can forget about display (use eclass for that ?)

src_configure() {
	gnome-meson_src_configure \
		$(meson_use test enable-tests) \
		$(meson_use systemd enable-systemd)
}

src_test() {
	"${EROOT}${GLIB_COMPILE_SCHEMAS}" --allow-any-name "${S}/data" || die
	GSETTINGS_SCHEMA_DIR="${S}/data" virtx meson_src_test
}
