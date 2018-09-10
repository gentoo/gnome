# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit gnome-meson virtualx
if [[ ${PV} = 9999 ]]; then
	SRC_URI=""
	EGIT_REPO_URI="https://gitlab.gnome.org/GNOME/epiphany.git"
	inherit git-r3
fi

DESCRIPTION="GNOME webbrowser based on Webkit"
HOMEPAGE="https://wiki.gnome.org/Apps/Web"

LICENSE="GPL-3+"
SLOT="0"
IUSE="test"
if [[ ${PV} = 9999 ]]; then
	KEYWORDS=""
else
	KEYWORDS="~amd64 ~arm ~ppc ~ppc64 ~sparc ~x86"
fi

COMMON_DEPEND="
	>=dev-libs/glib-2.52.0:2
	>=x11-libs/gtk+-3.22.13:3
	>=dev-libs/nettle-3.2:=
	>=net-libs/webkit-gtk-2.17.4:4=
	>=x11-libs/cairo-1.2
	>=app-crypt/gcr-3.5.5:=[gtk]
	>=x11-libs/gdk-pixbuf-2.36.5:2
	>=gnome-base/gnome-desktop-2.91.2:3=
	dev-libs/icu:=
	>=app-text/iso-codes-0.35
	>=dev-libs/json-glib-1.2.4
	>=x11-libs/libnotify-0.5.1
	>=app-crypt/libsecret-0.14
	>=net-libs/libsoup-2.48:2.4
	>=dev-libs/libxml2-2.6.12:2
	>=dev-libs/libxslt-1.1.7
	dev-db/sqlite:3
	dev-libs/gmp:0=
	>=gnome-base/gsettings-desktop-schemas-0.0.1
"
RDEPEND="${COMMON_DEPEND}
	x11-themes/adwaita-icon-theme
"
# paxctl needed for bug #407085
DEPEND="${COMMON_DEPEND}
	app-text/yelp-tools
	dev-util/gdbus-codegen
	sys-apps/paxctl
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

PATCHES=(
	# https://bugzilla.gnome.org/show_bug.cgi?id=751591
	# ephy-file-helpers tests are currently disabled due to https://gitlab.gnome.org/GNOME/epiphany/issues/419
	# So this patch is currently without effect. Retest with PORTAGE_TMPDIR=/var/tmp once re-enabled upstream.
	#"${FILESDIR}"/${PN}-3.16.0-unittest-1.patch
)

src_configure() {
	# https_everywhere removed in 3.28
	gnome-meson_src_configure \
		-Ddeveloper_mode=false \
		-Ddistributor_name=Gentoo \
		-Dhttps_everywhere=false \
		$(meson_use test unit_tests)
}

src_test() {
	virtx meson_src_test
}
