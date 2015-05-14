# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/babl/babl-0.1.10-r1.ebuild,v 1.12 2015/01/29 17:27:42 mgorny Exp $

EAPI=5

inherit autotools eutils

DESCRIPTION="A dynamic, any to any, pixel format conversion library"
HOMEPAGE="http://www.gegl.org/babl/"
SRC_URI="http://ftp.gimp.org/pub/${PN}/${PV:0:3}/${P}.tar.bz2"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~amd64-fbsd ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE="altivec cpu_flags_x86_sse cpu_flags_x86_sse2 cpu_flags_x86_mmx"

RDEPEND=""
DEPEND="${RDEPEND}
	>=sys-devel/libtool-2.2
	virtual/pkgconfig
"

src_configure() {
	# Automagic rsvg support is just for website generation we do not call,
	#     so we don't need to fix it
	# w3m is used for dist target thus no issue for us that it is automagically
	#     detected
	econf \
		--disable-docs \
		--disable-static \
		--disable-maintainer-mode \
		$(use_enable altivec) \
		$(use_enable cpu_flags_x86_mmx mmx) \
		$(use_enable cpu_flags_x86_sse sse) \
		$(use_enable cpu_flags_x86_sse sse2)
}

src_install() {
	default
	prune_libtool_files --all
	dodoc AUTHORS ChangeLog README NEWS
}
