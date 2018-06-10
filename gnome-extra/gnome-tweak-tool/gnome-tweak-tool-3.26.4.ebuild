# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME2_LA_PUNT="yes"
PYTHON_COMPAT=( python3_{4,5,6} )

inherit gnome-meson python-r1

DESCRIPTION="Tool to customize GNOME 3 options"
HOMEPAGE="https://wiki.gnome.org/action/show/Apps/GnomeTweakTool"

LICENSE="GPL-2+"
SLOT="0"

IUSE=""
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

KEYWORDS="~amd64 ~ia64 ~x86"

COMMON_DEPEND="
	${PYTHON_DEPS}
	dev-libs/glib:2[dbus]
	>=dev-python/pygobject-3.10.2:3[${PYTHON_USEDEP}]
	>=gnome-base/gsettings-desktop-schemas-3.23.3
"
# g-s-d, gnome-desktop, gnome-shell etc. needed at runtime for the gsettings schemas
RDEPEND="${COMMON_DEPEND}
	>=gnome-base/gnome-desktop-3.6.0.1:3=[introspection]
	>=x11-libs/gtk+-3.12:3[introspection]

	net-libs/libsoup:2.4[introspection]
	x11-libs/libnotify[introspection]

	>=gnome-base/gnome-settings-daemon-3
	>=gnome-base/gnome-shell-3.24
	>=gnome-base/nautilus-3
"
DEPEND="${COMMON_DEPEND}
	sys-devel/gettext
	>=dev-util/intltool-0.40.0
	virtual/pkgconfig
"
run_in_sane_meson_variables() {
	local EMESON_SOURCE
	EMESON_SOURCE=${BUILD_DIR}
	BUILD_DIR="${BUILD_DIR}-build"
	"$@"
	BUILD_DIR=${EMESON_SOURCE}
}

src_prepare() {
	# Add contents of Gentoo's cursor theme directory to cursor theme list
	eapply "${FILESDIR}/${PN}-3.26.4-gentoo-cursor-themes.patch"

	gnome-meson_src_prepare
	python_copy_sources
}

src_configure() {
	python_foreach_impl run_in_build_dir run_in_sane_meson_variables gnome-meson_src_configure
}

src_compile() {
	python_foreach_impl run_in_build_dir run_in_sane_meson_variables gnome-meson_src_compile
}

src_test() {
	python_foreach_impl run_in_build_dir run_in_sane_meson_variables meson_src_test
}

src_install() {
	python_foreach_impl run_in_build_dir run_in_sane_meson_variables gnome-meson_src_install
	python_foreach_impl run_in_build_dir python_doscript gnome-tweak-tool || die
}
