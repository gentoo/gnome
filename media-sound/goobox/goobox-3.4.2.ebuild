# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit gnome2

DESCRIPTION="Goobox is a CD player for the GNOME desktop environment"
HOMEPAGE="https://people.gnome.org/~paobac/goobox/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="libnotify"

RDEPEND="
	>=app-cdr/brasero-3
	>=dev-libs/glib-2.36:2
	media-libs/gstreamer:1.0
	media-libs/libdiscid
	media-libs/musicbrainz:5
	media-plugins/gst-plugins-cdparanoia:1.0
	media-plugins/gst-plugins-meta:1.0
	>=x11-libs/gtk+-3.10:3
	libnotify? ( >=x11-libs/libnotify-0.4.3 )
"
DEPEND="${DEPEND}
	app-text/yelp-tools
	>=dev-util/intltool-0.50.1
	sys-devel/gettext
	virtual/pkgconfig
"

src_configure() {
	# libcoverart is not available in tree
	gnome2_src_configure \
		--disable-libcoverart \
		--enable-media-keys \
		$(use_enable libnotify notification)
}
