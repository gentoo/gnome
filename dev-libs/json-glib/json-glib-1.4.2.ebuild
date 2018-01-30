# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit gnome.org gnome-meson multilib-minimal

DESCRIPTION="Library providing GLib serialization and deserialization for the JSON format"
HOMEPAGE="https://wiki.gnome.org/Projects/JsonGlib"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sparc ~x86 ~amd64-fbsd ~x86-fbsd"
IUSE="doc +introspection"

RDEPEND="
	>=dev-libs/glib-2.44:2[${MULTILIB_USEDEP}]
	introspection? ( >=dev-libs/gobject-introspection-0.9.5:= )
"
DEPEND="${RDEPEND}
	doc? (
		~app-text/docbook-xml-dtd-4.1.2
		app-text/docbook-xsl-stylesheets
		dev-libs/libxslt
		dev-util/gtk-doc
	)
	>=sys-devel/gettext-0.18
	virtual/pkgconfig[${MULTILIB_USEDEP}]
"

multilib_src_configure() {
	gnome-meson_src_configure \
		-Ddocs=true \
		$(meson_use introspection)
}

multilib_src_compile() {
	gnome-meson_src_compile
}

multilib_src_test() {
	meson_src_test
}

multilib_src_install() {
	gnome-meson_src_install
}
