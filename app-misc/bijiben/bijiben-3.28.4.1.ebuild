# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit gnome.org gnome2-utils meson xdg

DESCRIPTION="Note editor designed to remain simple to use"
HOMEPAGE="https://wiki.gnome.org/Apps/Bijiben"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	>=app-misc/tracker-1:=
	>=dev-libs/glib-2.53.4:2
	net-libs/gnome-online-accounts:=
	>=x11-libs/gtk+-3.19.3:3
	>=gnome-extra/evolution-data-server-3.13.90:=
	dev-libs/libxml2:2
	sys-apps/util-linux
	>=net-libs/webkit-gtk-2.10.0:4
"
DEPEND="${RDEPEND}
	dev-util/itstool
	dev-util/gdbus-codegen
	>=dev-util/intltool-0.50.1
	>=sys-devel/gettext-0.19.7
	virtual/pkgconfig
"
