# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit gnome2

DESCRIPTION="Personal task manager"
HOMEPAGE="https://wiki.gnome.org/Apps/Todo"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+introspection"

RDEPEND="
	>=dev-libs/glib-2.43.4:2
	>=dev-libs/libical-0.43
	>=dev-libs/libpeas-1.17
	>=gnome-extra/evolution-data-server-3.17.1:=[gtk]
	>=net-libs/gnome-online-accounts-3.2
	>=x11-libs/gtk+-3.22.0:3
	introspection? ( >=dev-libs/gobject-introspection-1.42:= )
"
DEPEND="${RDEPEND}
	dev-libs/appstream-glib
	>=dev-util/gtk-doc-am-1.14
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}"/${PV}-libical3-compat.patch
)

src_configure() {
	gnome2_src_configure \
		$(use_enable introspection) \
		--enable-eds-plugin \
		--enable-background-plugin \
		--enable-dark-theme-plugin \
		--enable-scheduled-panel-plugin \
		--enable-score-plugin \
		--enable-today-panel-plugin \
		--enable-unscheduled-panel-plugin \
		--enable-todo-txt-plugin
}
