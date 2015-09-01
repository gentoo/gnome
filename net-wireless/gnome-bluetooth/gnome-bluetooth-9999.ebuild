# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"
GCONF_DEBUG="yes"

inherit eutils gnome2 udev user
if [[ ${PV} = 9999 ]]; then
	inherit gnome2-live
fi

DESCRIPTION="Bluetooth graphical utilities integrated with GNOME"
HOMEPAGE="https://wiki.gnome.org/GnomeBluetooth"

LICENSE="GPL-2+ LGPL-2.1+ FDL-1.1+"
SLOT="2/13" # subslot = libgnome-bluetooth soname version
IUSE="+introspection"
if [[ ${PV} = 9999 ]]; then
	IUSE="${IUSE} doc"
	KEYWORDS=""
else
	KEYWORDS="~amd64 ~arm ~ppc ~ppc64 ~x86"
fi

COMMON_DEPEND="
	>=dev-libs/glib-2.38:2
	>=x11-libs/gtk+-3.12:3[introspection?]
	virtual/udev
	introspection? ( >=dev-libs/gobject-introspection-0.9.5 )
"
RDEPEND="${COMMON_DEPEND}
	>=net-wireless/bluez-5
	x11-themes/gnome-icon-theme-symbolic
"
DEPEND="${COMMON_DEPEND}
	!net-wireless/bluez-gnome
	app-text/docbook-xml-dtd:4.1.2
	dev-libs/libxml2:2
	dev-util/gdbus-codegen
	>=dev-util/gtk-doc-am-1.9
	>=dev-util/intltool-0.40.0
	virtual/libudev
	virtual/pkgconfig
	x11-proto/xproto
"
# eautoreconf needs:
#	gnome-base/gnome-common

if [[ ${PV} = 9999 ]]; then
	DEPEND="${DEPEND}
		app-text/yelp-tools
		doc? ( >=dev-util/gtk-doc-1.9 )"
fi

pkg_setup() {
	enewgroup plugdev
}

src_prepare() {
	# Regenerate gdbus-codegen files to allow using any glib version; bug #436236
	if [[ ${PV} != 9999 ]]; then
		rm -v lib/bluetooth-client-glue.{c,h} || die
	fi
	gnome2_src_prepare
}

src_configure() {
	local myconf=""
	[[ ${PV} != 9999 ]] && myconf="ITSTOOL=$(type -P true)"
	gnome2_src_configure \
		$(use_enable introspection) \
		--enable-documentation \
		--disable-desktop-update \
		--disable-icon-update \
		--disable-static \
		${myconf}
}

src_install() {
	gnome2_src_install
	udev_dorules "${FILESDIR}"/61-${PN}.rules
}

pkg_postinst() {
	gnome2_pkg_postinst
	if ! has_version sys-auth/consolekit[acl] && ! has_version sys-apps/systemd[acl] ; then
		elog "Don't forget to add yourself to the plugdev group "
		elog "if you want to be able to control bluetooth transmitter."
	fi
}
