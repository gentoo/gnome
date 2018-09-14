# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils
if [[ ${PV} = 9999 ]]; then
	inherit gnome2-live # to avoid duplicating hacks from gnome2-live_src_prepare
fi

DESCRIPTION="Provides a standard configuration setup for installing PKCS#11."
HOMEPAGE="http://p11-glue.freedesktop.org/p11-kit.html"
if [[ ${PV} = 9999 ]]; then
	EGIT_REPO_URI="git://anongit.freedesktop.org/p11-glue/p11-kit"
else
	SRC_URI="http://p11-glue.freedesktop.org/releases/${P}.tar.gz"
fi

LICENSE="MIT"
SLOT="0"
if [[ ${PV} = 9999 ]]; then
	KEYWORDS=""
else
	KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x86-linux"
fi
IUSE="+asn1 debug +trust"
REQUIRED_USE="trust? ( asn1 )"

RDEPEND="asn1? ( >=dev-libs/libtasn1-2.14 )"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

src_configure() {
	econf \
		$(use_enable trust trust-module) \
		$(use_enable debug) \
		$(use_with asn1 libtasn1)
}

src_install() {
	default
	prune_libtool_files --modules
}
