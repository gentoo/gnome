# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit gnome.org gnome2-utils meson virtualx xdg

DESCRIPTION="Library with common API for various GNOME modules"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gnome-desktop/"

LICENSE="GPL-2+ FDL-1.1+ LGPL-2+"
SLOT="3/17" # subslot = libgnome-desktop-3 soname version
IUSE="debug doc +introspection gtk-doc seccomp udev"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd ~amd64-linux ~x86-linux ~x86-solaris"

# cairo[X] needed for gnome-bg
COMMON_DEPEND="
	app-text/iso-codes
	>=dev-libs/glib-2.53.0:2
	>=x11-libs/gdk-pixbuf-2.36.5:2[introspection?]
	>=x11-libs/gtk+-3.3.6:3[X,introspection?]
	x11-libs/cairo:=[X]
	x11-libs/libX11
	x11-misc/xkeyboard-config
	>=gnome-base/gsettings-desktop-schemas-3.27.0
	introspection? ( >=dev-libs/gobject-introspection-0.9.7:= )
	seccomp? ( sys-libs/libseccomp )
	udev? (
		sys-apps/hwids
		virtual/libudev:= )
"
RDEPEND="${COMMON_DEPEND}
	!<gnome-base/gnome-desktop-2.32.1-r1:2[doc]
	seccomp? ( sys-apps/bubblewrap )
"
DEPEND="${COMMON_DEPEND}
	app-text/docbook-xml-dtd:4.1.2
	dev-util/gdbus-codegen
	dev-util/itstool
	>=sys-devel/gettext-0.19.8
	x11-base/xorg-proto
	virtual/pkgconfig
	media-libs/fontconfig
	app-text/yelp-tools
"
PATCHES=(
	"${FILESDIR}/${PV}-make-seccomp-optional.patch"
)
src_configure() {
	local emesonargs=(
		-Dgnome_distributor=Gentoo
		$(meson_use debug debug_tools)
		-Dudev=$(usex udev enabled disabled)
		$(meson_use gtk-doc gtk_doc)
		$(meson_use doc desktop_docs)
		$(meson_use seccomp)
	)
	meson_src_configure
}

src_test() {
	virtx meson_src_test
}
