# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python2_7 )

inherit distutils-r1 gnome2-utils fdo-mime

DESCRIPTION=""
HOMEPAGE="https://fedorahosted.org/dogtail/"
SRC_URI="https://fedorahosted.org/released/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="
	dev-libs/gobject-introspection
	dev-python/pyatspi[${PYTHON_USEDEP}]
	dev-python/pycairo[${PYTHON_USEDEP}]
	dev-python/pygobject:3[${PYTHON_USEDEP}]
	virtual/python-imaging[${PYTHON_USEDEP}]
	x11-libs/gdk-pixbuf:2[introspection]
	x11-libs/gtk+:3[introspection]
	x11-libs/libwnck:3[introspection]
	x11-base/xorg-server[xvfb]
	x11-apps/xinit
"
DEPEND="${DEPEND}"

src_prepare() {
	# Install docs in one place
	sed "s:doc/${PN}:doc/${PF}:" -i setup.py || die

	distutils-r1_src_prepare
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}
