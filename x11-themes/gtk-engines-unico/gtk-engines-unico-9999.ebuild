# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

AUTOTOOLS_AUTORECONF=yes
AUTOTOOLS_PRUNE_LIBTOOL_FILES=modules

inherit autotools-multilib eutils
if [[ ${PV} = 9999 ]]; then
	EBZR_REPO_URI="lp:unico"
	inherit bzr
fi

MY_PN=${PN/gtk-engines-}
MY_PV=${PV/_pre/+14.04.}
MY_P=${MY_PN}_${MY_PV}

DESCRIPTION="The Unico GTK+ 3.x theming engine"
HOMEPAGE="https://launchpad.net/unico"
if [[ ${PV} != 9999 ]]; then
	SRC_URI="https://launchpad.net/ubuntu/+archive/primary/+files/${MY_P}.orig.tar.gz"
	S=${WORKDIR}/${MY_PN}-${MY_PV}
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
	>=dev-libs/glib-2.26:2[${MULTILIB_USEDEP}]
	>=x11-libs/cairo-1.10[glib,${MULTILIB_USEDEP}]
	>=x11-libs/gtk+-3.5.2:3[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

src_unpack() {
	bzr_src_unpack
}

src_configure() {
	# $(use_enable debug) controls CPPFLAGS -D_DEBUG and -DNDEBUG but they are currently
	# unused in the code itself.
	autotools-multilib_src_configure \
		--disable-static \
		--disable-debug \
		--disable-maintainer-flags
}
