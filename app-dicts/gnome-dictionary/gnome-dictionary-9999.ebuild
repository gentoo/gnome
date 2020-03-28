# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit gnome-meson git-r3

DESCRIPTION="Dictionary utility for GNOME"
HOMEPAGE="https://wiki.gnome.org/Apps/Dictionary"
SRC_URI=""
EGIT_REPO_URI="https://gitlab.gnome.org/GNOME/gnome-dictionary.git"

LICENSE="GPL-2+ LGPL-2.1+ FDL-1.1+"
SLOT="0" # does not provide a public libgdict-1.0.so anymore
IUSE="ipv6"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd ~amd64-linux ~x86-linux"

COMMON_DEPEND="
	>=dev-libs/glib-2.42:2
	>=x11-libs/gtk+-3.21.2:3
"
RDEPEND="${COMMON_DEPEND}
	gnome-base/gsettings-desktop-schemas
"
DEPEND="${COMMON_DEPEND}
	app-text/docbook-xsl-stylesheets
	app-text/docbook-xml-dtd:4.3
	dev-libs/libxslt
	dev-util/glib-utils
	dev-util/itstool
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

src_configure() {
	gnome-meson_src_configure \
		-Dbuild_man=true \
		$(meson_use ipv6 use_ipv6)
}
