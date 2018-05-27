# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
VALA_USE_DEPEND="vapigen"
VALA_MIN_API_VERSION="0.24"

inherit git-r3 gnome-meson vala

DESCRIPTION="GNOME contact management application"
HOMEPAGE="https://wiki.gnome.org/Design/Apps/Contacts"
SRC_URI=""
EGIT_REPO_URI="https://gitlab.gnome.org/GNOME/gnome-contacts.git"

LICENSE="GPL-2+"
SLOT="0"
IUSE="v4l"
if [[ ${PV} = 9999 ]]; then
	KEYWORDS=""
else
	KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~sparc ~x86"
fi

VALA_DEPEND="
	$(vala_depend)
	>=dev-libs/gobject-introspection-0.9.6:=
	dev-libs/folks[vala(+)]
	gnome-base/gnome-desktop:3=[introspection]
	gnome-extra/evolution-data-server[vala]
	net-libs/telepathy-glib[vala]
"
# Configure is wrong; it needs cheese-3.5.91, not 3.3.91
RDEPEND="
	>=dev-libs/folks-0.11.4:=[eds,telepathy]
	>=dev-libs/glib-2.44:2
	>=dev-libs/libgee-0.10:0.8
	>=gnome-extra/evolution-data-server-3.13.90:=[gnome-online-accounts]
	>=gnome-base/gnome-desktop-3.0:3=
	media-libs/clutter:1.0
	media-libs/clutter-gtk:1.0
	media-libs/libchamplain:0.12
	net-libs/gnome-online-accounts:=[vala]
	>=net-libs/telepathy-glib-0.22
	>=sci-geosciences/geocode-glib-3.15.3
	x11-libs/cairo:=
	x11-libs/gdk-pixbuf:2
	>=x11-libs/gtk+-3.22:3
	x11-libs/pango
	v4l? ( >=media-video/cheese-3.5.91:= )
"
DEPEND="${RDEPEND}
	${VALA_DEPEND}
	app-text/docbook-xml-dtd:4.2
	app-text/docbook-xsl-stylesheets
	dev-libs/libxslt
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
"

src_unpack() {
	git-r3_src_unpack
}

src_prepare() {
	# Regenerate the pre-generated C sources, bug #471628
	if ! use v4l; then
		touch src/*.vala
	fi

	vala_src_prepare
	gnome-meson_src_prepare
}

src_configure() {
	gnome-meson_src_configure \
		-Dwith-manpage=true \
		$(meson_use v4l with-cheese)
}
