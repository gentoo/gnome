# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

DESCRIPTION="Library to handle input devices in Wayland"
HOMEPAGE="http://www.freedesktop.org/wiki/Software/libinput/"
SRC_URI="http://www.freedesktop.org/software/${PN}/${P}.tar.xz"

# License appears to be a variant of libtiff
LICENSE="libtiff"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc gtk test"

RDEPEND="
	>=dev-libs/libevdev-0.4
	>=sys-libs/mtdev-1.1
	virtual/libudev
	gtk? (
		dev-libs/glib:2
		x11-libs/cairo
		x11-libs/gtk+:3 )
"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )
	test? ( >=dev-libs/check-0.9.10 )
"
# tests can even use: dev-util/valgrind

src_configure() {
	econf \
		$(use_enable gtk event-gui) \
		$(use_enable test tests) \
		DOXYGEN=$(usex doc $(type -P doxygen) "")
}
