# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils
if [[ ${PV} = 9999 ]]; then
	EBZR_REPO_URI="lp:unico"
	GCONF_DEBUG="no"
	inherit bzr gnome2-live # need gnome2-live for generating the build system
fi

MY_PN=${PN/gtk-engines-}
MY_P=${MY_PN}-${PV}

DESCRIPTION="The Unico GTK+ 3.x theming engine"
HOMEPAGE="https://launchpad.net/unico"
if [[ ${PV} != 9999 ]]; then
	SRC_URI="https://launchpad.net/ubuntu/oneiric/+source/gtk3-engines-unico/${MY_PV}-0ubuntu1/+files/gtk3-engines-unico_${MY_PV}.orig.tar.gz"
	S="${WORKDIR}/${MY_PN}-${MY_PV}"
fi

LICENSE="LGPL-2.1+"
SLOT="0"
IUSE=""
if [[ ${PV} = 9999 ]]; then
	KEYWORDS=""
else
	KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
fi

RDEPEND="
	>=dev-libs/glib-2.26:2
	>=x11-libs/cairo-1.10[glib]
	>=x11-libs/gtk+-3.5.2:3
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

src_unpack() {
	if [[ ${PV} = 9999 ]]; then
		bzr_src_unpack
	else
		default
	fi
}

src_prepare() {
	if [[ ${PV} = 9999 ]]; then
		gnome2-live_src_prepare
	else
		default
	fi
}

src_configure() {
	# $(use_enable debug) controls CPPFLAGS -D_DEBUG and -DNDEBUG but they are currently
	# unused in the code itself.
	econf \
		--disable-static \
		--disable-debug \
		--disable-maintainer-flags
}

src_install() {
	DOCS="AUTHORS NEWS" # ChangeLog, README are empty
	default
	prune_libtool_files --modules
}
