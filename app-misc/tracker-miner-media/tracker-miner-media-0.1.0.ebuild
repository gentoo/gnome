# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"
GCONF_DEBUG="no"

inherit autotools eutils gnome2

DESCRIPTION="Fetches additional metadata from online resources for media files for tracker"
HOMEPAGE="https://wiki.gnome.org/Projects/Tracker"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="
	app-misc/tracker:0=
	>=dev-libs/libgdata-0.17:0=
"
DEPEND="${DEPEND}
	>=dev-util/intltool-0.40
	virtual/pkgconfig
"

src_prepare() {
	# Fix content of dbus service and desktop files.
	epatch "${FILESDIR}"/${PN}-0.1.0-dbus-service.patch

	eautoreconf
	gnome2_src_prepare
}

src_install() {
	gnome2_src_install \
		miner_descdir=/etc/xdg/autostart

	local service="org.freedesktop.Tracker1.Miner.Media.service"
	dosym /usr/share/dbus-1/services/${service} /usr/share/tracker/miners/${service}
}
