# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME2_LA_PUNT="yes" # Needed with USE 'sendto'

inherit gnome.org gnome2-utils meson readme.gentoo-r1 virtualx xdg
if [[ ${PV} = 9999 ]]; then
	inherit git-r3
	SRC_URI=""
	EGIT_SRC_URI="https://gitlab.gnome.org/GNOME/${PN}"
fi

DESCRIPTION="A file manager for the GNOME desktop"
HOMEPAGE="https://wiki.gnome.org/Apps/Nautilus"

LICENSE="GPL-2+ LGPL-2+ FDL-1.1"
SLOT="0"
IUSE="exif gnome gtk-doc +introspection packagekit +previewer selinux sendto tracker xmp"

KEYWORDS=""

# FIXME: tests fails under Xvfb, but pass when building manually
# "FAIL: check failed in nautilus-file.c, line 8307"
# need org.gnome.SessionManager service (aka gnome-session) but cannot find it
RESTRICT="test"

# Require {glib,gdbus-codegen}-2.30.0 due to GDBus API changes between 2.29.92
# and 2.30.0
COMMON_DEPEND="
	>=app-arch/gnome-autoar-0.2.1
	>=dev-libs/glib-2.51.2:2[dbus]
	>=x11-libs/pango-1.28.3
	>=x11-libs/gtk+-3.22.6:3[introspection?]
	>=dev-libs/libxml2-2.7.8:2
	>=gnome-base/gnome-desktop-3:3=

	>=gnome-base/gsettings-desktop-schemas-3.8.0
	x11-libs/libX11

	exif? ( >=media-libs/libexif-0.6.20 )
	introspection? ( >=dev-libs/gobject-introspection-0.6.4:= )
	selinux? ( >=sys-libs/libselinux-2 )
	tracker? ( >=app-misc/tracker-2:= )
	xmp? ( >=media-libs/exempi-2.1.0:2 )
"
DEPEND="${COMMON_DEPEND}
	>=dev-util/gdbus-codegen-2.33
	>=sys-devel/gettext-0.19.7
	virtual/pkgconfig
	x11-base/xorg-proto

	gtk-doc? ( dev-util/gtk-doc )
"
RDEPEND="${COMMON_DEPEND}
	gnome-base/dconf
	packagekit? ( app-admin/packagekit-base )
	sendto? ( !<gnome-extra/nautilus-sendto-3.0.1 )
"
PDEPEND="
	gnome? ( x11-themes/adwaita-icon-theme )
	previewer? ( >=gnome-extra/sushi-0.1.9 )
	sendto? ( >=gnome-extra/nautilus-sendto-3.0.1 )
	>=gnome-base/gvfs-1.34
"

PATCHES=(
	# Keep tracker optional
	"${FILESDIR}"/${PV}-tracker-support-optional.patch
)

src_prepare() {
	if use previewer; then
		DOC_CONTENTS="nautilus uses gnome-extra/sushi to preview media files.
			To activate the previewer, select a file and press space; to
			close the previewer, press space again."
	fi
	xdg_src_prepare
}

src_configure() {
	local emesonargs=(
		"-Denable-desktop=true"
		"-Denable-profiling=false"
		"-Dtracker=$(usex tracker auto disabled)"
		$(meson_use gtk-doc enable-gtk-doc)
		$(meson_use exif enable-exif)
		$(meson_use packagekit enable-packagekit)
		$(meson_use sendto enable-nst-extension)
		$(meson_use selinux enable-selinux)
		$(meson_use xmp enable-xmp)
	)
	meson_src_configure
}

src_test() {
	virtx meson_src_test
}

src_install() {
	use previewer && readme.gentoo_create_doc
	meson_src_install
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_icon_cache_update
	gnome2_schemas_update

	if use previewer; then
		readme.gentoo_print_elog
	else
		elog "To preview media files, emerge nautilus with USE=previewer"
	fi
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_icon_cache_update
	gnome2_schemas_update
}
