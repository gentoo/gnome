# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit gnome-meson vala

DESCRIPTION="Simple document scanning utility"
HOMEPAGE="https://launchpad.net/simple-scan"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="colord webp" # packagekit

COMMON_DEPEND="
	>=dev-libs/glib-2.38:2
	>=dev-libs/libgusb-0.2.7
	>=media-gfx/sane-backends-1.0.20:=
	>=sys-libs/zlib-1.2.3.1:=
	virtual/jpeg:0=
	x11-libs/cairo:=
	>=x11-libs/gtk+-3.12:3
	x11-libs/gdk-pixbuf:2
	colord? ( >=x11-misc/colord-0.1.24:=[udev] )
	webp? ( media-libs/libwebp )
"
# packagekit? ( >=app-admin/packagekit-base-1.1.5 )
RDEPEND="${COMMON_DEPEND}
	x11-misc/xdg-utils
	x11-themes/adwaita-icon-theme
"
DEPEND="${COMMON_DEPEND}
	$(vala_depend)
	app-text/yelp-tools
	dev-libs/appstream-glib
	>=sys-devel/gettext-0.19.7
	virtual/pkgconfig
	>=dev-libs/libgusb-0.2.7[vala]
	colord? ( >=x11-misc/colord-0.1.24:=[vala] )
"

PATCHES=(
	# Add control for optional dependencies
	"${FILESDIR}"/3.26-add-control-optional-deps.patch
)

src_prepare() {
	vala_src_prepare
	gnome-meson_src_prepare
}

src_configure() {
	gnome-meson_src_configure \
		-Dpackagekit=false \
		$(meson_use colord) \
		$(meson_use webp)
}
