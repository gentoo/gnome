# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
GCONF_DEBUG="no"

inherit gnome2

DESCRIPTION="Goobox is a CD player for the GNOME desktop environment"
HOMEPAGE="https://people.gnome.org/~paobac/goobox/"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="
	>=app-cdr/brasero-3
	>=dev-libs/glib-2.36:2
	media-libs/gstreamer:1.0
	media-libs/libdiscid
	media-libs/musicbrainz:5
	media-plugins/gst-plugins-cdparanoia:1.0
	media-plugins/gst-plugins-meta:1.0
	>=x11-libs/gtk+-3.10:3
	>=x11-libs/libnotify-0.4.3
"
DEPEND="${DEPEND}
	dev-libs/libxml2
	>=dev-util/intltool-0.35
	virtual/pkgconfig
"

src_configure() {
	# libcoverart is not available in tree
	gnome2_src_configure \
		--disable-libcoverart \
		--enable-media-keys \
		--enable-notification
}
