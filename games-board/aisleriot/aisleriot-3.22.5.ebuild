# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME2_EAUTORECONF="yes"

inherit gnome2

DESCRIPTION="A collection of solitaire card games for GNOME"
HOMEPAGE="https://wiki.gnome.org/action/show/Apps/Aisleriot"

LICENSE="GPL-3 LGPL-3 FDL-1.3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug gnome qt5"

# FIXME: quartz support?
# Does not build with guile-2.0.0 or 2.0.1
COMMON_DEPEND="
	>=dev-libs/glib-2.32:2
	>=dev-scheme/guile-2.0.5:12[deprecated,regex]
	<dev-scheme/guile-2.1
	>=gnome-base/librsvg-2.32:2
	>=media-libs/libcanberra-0.26[gtk3]
	>=x11-libs/cairo-1.10
	>=x11-libs/gtk+-3.4:3
	gnome? ( >=gnome-base/gconf-2.0:2 )
	qt5? ( >=dev-qt/qtsvg-5:5 )
"
DEPEND="${COMMON_DEPEND}
	app-arch/gzip
	app-text/yelp-tools
	>=dev-util/intltool-0.40.4
	gnome-base/gnome-common
	sys-apps/lsb-release
	sys-devel/autoconf-archive
	>=sys-devel/gettext-0.12
	virtual/pkgconfig
	gnome? ( app-text/docbook-xml-dtd:4.3 )
"

PATCHES=(
	# Fix SVG detection and usage
	"${FILESDIR}"/${PN}-3.22.0-detect-svg.patch
	# Fix build with Qt5, bug #617256
	"${FILESDIR}"/${PN}-3.22.2-qt5-requires-cxx11.patch
)

src_configure() {
	local myconf=()

	if use gnome; then
		myconf+=(
			--with-platform=gnome
			--with-help-method=ghelp
		)
	else
		myconf+=(
			--with-platform=gtk-only
			--with-help-method=library
		)
	fi

	if use qt5 ; then
		myconf+=(
			--with-card-theme-formats=all
			--with-kde-card-theme-path="${EPREFIX}"/usr/share/apps/carddecks
		)
	else
		myconf+=( --with-card-theme-formats=svg,fixed,pysol )
	fi

	gnome2_src_configure \
		--with-gtk=3.0 \
		--with-guile=2.0 \
		$(usex debug --enable-debug=yes --enable-debug=minimum) \
		--enable-sound \
		--with-pysol-card-theme-path="${EPREFIX}${GAMES_DATADIR}"/pysolfc \
		${myconf[@]}
}

pkg_postinst() {
	gnome2_pkg_postinst

	elog "Aisleriot can use additional card themes from games-board/pysolfc"
	elog "and kde-base/libkdegames."
}
