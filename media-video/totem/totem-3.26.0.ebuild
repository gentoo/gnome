# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python{3_4,3_5,3_6} )
PYTHON_REQ_USE="threads"

inherit gnome-meson python-single-r1 vala

DESCRIPTION="Media player for GNOME"
HOMEPAGE="https://wiki.gnome.org/Apps/Videos"

LICENSE="GPL-2+ LGPL-2+"
SLOT="0"
IUSE="cdr +introspection lirc nautilus +python test vala"
# see bug #359379
REQUIRED_USE="
	python? ( introspection ${PYTHON_REQUIRED_USE} )
"

KEYWORDS="~amd64 ~arm ~arm64 ~ia64 ~ppc ~ppc64 ~x86 ~x86-fbsd"

# FIXME:
# Runtime dependency on gnome-session-2.91
COMMON_DEPEND="
	>=dev-libs/glib-2.43.4:2[dbus]
	>=dev-libs/libpeas-1.1[gtk]
	>=dev-libs/totem-pl-parser-3.10.1:0=[introspection?]
	>=media-libs/clutter-1.17.3:1.0[gtk]
	>=media-libs/clutter-gst-2.99.2:3.0
	>=media-libs/clutter-gtk-1.8.1:1.0
	>=x11-libs/cairo-1.14
	>=x11-libs/gdk-pixbuf-2.23.0:2
	>=x11-libs/gtk+-3.19.4:3[introspection?]

	>=media-libs/grilo-0.3.0:0.3[playlist]
	>=media-libs/gstreamer-1.6.0:1.0
	>=media-libs/gst-plugins-base-1.6.0:1.0[X,introspection?,pango]
	media-libs/gst-plugins-good:1.0

	x11-libs/libX11

	gnome-base/gnome-desktop:3=
	gnome-base/gsettings-desktop-schemas

	cdr? (
		>=dev-libs/libxml2-2.6:2
		>=x11-libs/gtk+-3.19.4:3[X]
	)
	introspection? ( >=dev-libs/gobject-introspection-0.6.7:= )
	lirc? ( app-misc/lirc )
	nautilus? ( >=gnome-base/nautilus-2.91.3 )
	python? (
		${PYTHON_DEPS}
		>=dev-python/pygobject-2.90.3:3[${PYTHON_USEDEP}] )
"
RDEPEND="${COMMON_DEPEND}
	media-plugins/grilo-plugins:0.3
	media-plugins/gst-plugins-meta:1.0
	media-plugins/gst-plugins-taglib:1.0
	x11-themes/adwaita-icon-theme
	python? (
		>=dev-libs/libpeas-1.1.0[python,${PYTHON_USEDEP}]
		dev-python/pyxdg[${PYTHON_USEDEP}]
		dev-python/dbus-python[${PYTHON_USEDEP}]
		>=x11-libs/gtk+-3.5.2:3[introspection] )
"
# libxml2+gdk-pixbuf required for glib-compile-resources
DEPEND="${COMMON_DEPEND}
	app-text/docbook-xml-dtd:4.5
	app-text/yelp-tools
	>=dev-libs/libxml2-2.6:2
	>=dev-util/meson-0.44
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	x11-base/xorg-proto
	vala? ( $(vala_depend) )
"
# docbook-xml-dtd is needed for user doc
# Prevent dev-python/pylint dep, bug #482538

PATCHES=(
	# Fix some typos in meson.build files
	"${FILESDIR}"/3.26-meson-fixes.patch
	# Do not force all plugins
	"${FILESDIR}"/3.26-control-plugins.patch
	# Do not force pylint with USE=python
	"${FILESDIR}"/3.26-skip-pylint-check.patch
	# Allow disabling calls to gst-inspect (sandbox issue)
	"${FILESDIR}"/3.26-gst-inspect-sandbox.patch
)

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	vala_src_prepare
	gnome-meson_src_prepare
}

src_configure() {
	# Disabled: sample-python, sample-vala, zeitgeist-dp
	# brasero-disc-recorder and gromit depend on GTK+ X11 backend and could be made optional
	# if totem itself didn't depend on it
	local plugins="apple-trailers,autoload-subtitles"
	plugins+=",im-status,media-player-keys,ontop"
	plugins+=",properties,recent,screensaver,screenshot"
	plugins+=",skipto,variable-rate,vimeo"
	use cdr && plugins+=",brasero-disc-recorder"
	use lirc && plugins+=",lirc"
	use nautilus && plugins+=",save-file"
	use python && plugins+=",dbusservice,pythonconsole,opensubtitles"
	use vala && plugins+=",rotation"
	plugins+=",gromit"

	# pylint is checked unconditionally, but is only used for make check
	# appstream-util overriding necessary until upstream fixes their macro
	# to respect configure switch
	gnome-meson_src_configure \
		-Denable-easy-codec-installation=yes \
		-Denable-gtk-doc=false \
		-Denable-introspection=$(usex introspection yes no) \
		-Denable-nautilus=$(usex nautilus yes no) \
		-Denable-python=$(usex python yes no) \
		-Denable-vala=$(usex vala yes no) \
	    -Dgst-inspect=false \
		-Dwith-plugins=${plugins}
}

src_install() {
	gnome-meson_src_install
	if use python ; then
		local plugin
		for plugin in dbusservice pythonconsole opensubtitles ; do
			python_optimize "${ED}"usr/$(get_libdir)/totem/plugins/${plugin}
		done
	fi
}
