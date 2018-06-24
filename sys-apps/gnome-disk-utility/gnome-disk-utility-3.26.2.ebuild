# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME2_LA_PUNT="yes"

inherit gnome-meson

DESCRIPTION="Disk Utility for GNOME using udisks"
HOMEPAGE="https://git.gnome.org/browse/gnome-disk-utility"

LICENSE="GPL-2+"
SLOT="0"
IUSE="fat gnome systemd"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86"

COMMON_DEPEND="
	>=app-arch/xz-utils-5.0.5
	>=app-crypt/libsecret-0.7
	>=dev-libs/glib-2.31:2[dbus]
	dev-libs/libpwquality
	>=media-libs/libcanberra-0.1[gtk3]
	>=media-libs/libdvdread-4.2.0
	>=sys-fs/udisks-2.7.2:2
	>=x11-libs/gtk+-3.16.0:3
	>=x11-libs/libnotify-0.7:=
	systemd? ( >=sys-apps/systemd-209:0= )
"
RDEPEND="${COMMON_DEPEND}
	x11-themes/adwaita-icon-theme
	fat? ( sys-fs/dosfstools )
	gnome? ( >=gnome-base/gnome-settings-daemon-3.8 )
"
# libxml2+gdk-pixbuf required for glib-compile-resources
DEPEND="${COMMON_DEPEND}
	dev-libs/appstream-glib
	dev-libs/libxslt
	dev-libs/libxml2:2
	>=dev-util/meson-0.41.0
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	x11-libs/gdk-pixbuf:2
"

src_configure() {
	gnome-meson_src_configure \
		$(meson_use gnome enable-gsd-plugin) \
		$(meson_use systemd enable-libsystemd)
}
