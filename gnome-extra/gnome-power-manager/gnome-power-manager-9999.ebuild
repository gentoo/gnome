# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit gnome-meson virtualx

inherit gnome-meson virtualx
if [[ ${PV} = 9999 ]]; then
	SRC_URI=""
	EGIT_REPO_URI="https://gitlab.gnome.org/GNOME/gnome-power-manager.git"
	inherit git-r3
fi

DESCRIPTION="GNOME power management service"
HOMEPAGE="https://projects.gnome.org/gnome-power-manager/"

LICENSE="GPL-2"
SLOT="0"
IUSE="test"
if [[ ${PV} = 9999 ]]; then
	KEYWORDS=""
else
	KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
fi

COMMON_DEPEND="
	>=dev-libs/glib-2.45.8:2
	>=x11-libs/gtk+-3.3.8:3
	>=x11-libs/cairo-1
	>=sys-power/upower-0.99:=
"
RDEPEND="${COMMON_DEPEND}
	x11-themes/adwaita-icon-theme
"
# libxml2 required for glib-compile-resources
DEPEND="${COMMON_DEPEND}
	app-text/docbook-sgml-dtd:4.1
	app-text/docbook-sgml-utils
	dev-libs/appstream-glib
	dev-libs/libxml2:2
	>=sys-devel/gettext-0.19.7
	x11-base/xorg-proto
	virtual/pkgconfig
	test? ( sys-apps/dbus )
"

# docbook-sgml-utils and docbook-sgml-dtd-4.1 used for creating man pages
# (files under ${S}/man).
# docbook-xml-dtd-4.4 and -4.1.2 are used by the xml files under ${S}/docs.

src_prepare() {
	# Drop debugger CFLAGS from configure
	# Touch configure.ac only if running eautoreconf, otherwise
	# maintainer mode gets triggered -- even if the order is correct
	sed -e 's:^CPPFLAGS="$CPPFLAGS -g"$::g' \
		-i configure || die "debugger sed failed"
	gnome2_src_prepare
}

src_configure() {
	gnome-meson_src_configure \
		$(meson_use test enable-tests)
}

src_test() {
	virtx meson_src_test
}
