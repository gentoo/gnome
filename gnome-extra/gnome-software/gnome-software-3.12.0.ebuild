# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
GCONF_DEBUG="no"

inherit gnome2 virtualx

DESCRIPTION=""
HOMEPAGE=""

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="" # test

RDEPEND="
	>=app-admin/packagekit-base-0.8.12
	dev-db/sqlite:3
	>=dev-libs/glib-2.39.1:2
	gnome-base/gnome-desktop:3
	>=gnome-base/gsettings-desktop-schemas-3.11.5
	net-libs/libsoup:2.4
	x11-libs/libnotify:0=
	>=x11-libs/gtk+-3.11.5:3
"
DEPEND="${DEPEND}
	dev-libs/libxslt
	>=dev-util/intltool-0.35
	virtual/pkgconfig
"
#	test? ( dev-util/valgrind )

src_prepare() {
	# valgrind fails with SIGTRAP
	sed -e 's/TESTS = .*/TESTS =/' \
		-i "${S}"/src/Makefile.{am,in} || die

	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		--enable-man \
		--disable-dogtail
}

src_test() {
	Xemake check
}
