# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME2_LA_PUNT="yes"
PYTHON_COMPAT=( python{3_4,3_5,3_6} )

inherit bash-completion-r1 gnome2 linux-info python-any-r1 virtualx

DESCRIPTION="A tagging metadata database, search tool and indexer"
HOMEPAGE="https://wiki.gnome.org/Projects/Tracker"

LICENSE="GPL-2+ LGPL-2.1+"
SLOT="0/2.0"
IUSE="elibc_glibc networkmanager stemmer upower unistring test"

KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~ia64 ~ppc ~ppc64 ~sparc ~x86"

# glibc-2.12 needed for SCHED_IDLE (see bug #385003)
RDEPEND="
	>=dev-db/sqlite-3.20:=
	>=dev-libs/glib-2.44:2
	>=dev-libs/gobject-introspection-0.9.5:=
	>=dev-libs/json-glib-1.0
	>=dev-libs/libxml2-2.6:2
	>=net-libs/libsoup-2.40:2.4
	>=sys-apps/dbus-1.3.1
	sys-apps/util-linux
	elibc_glibc? ( >=sys-libs/glibc-2.12 )
	networkmanager? ( >=net-misc/networkmanager-0.8 )
	stemmer? ( dev-libs/snowball-stemmer )
	unistring? ( dev-libs/libunistring )
	!unistring? ( >=dev-libs/icu-4.8.1.1:= )
	upower? ( >=sys-power/upower-0.9 )
"
DEPEND="${RDEPEND}
	dev-util/gdbus-codegen
	>=dev-util/gtk-doc-am-1.8
	>=dev-util/intltool-0.40
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
	test? ( ${PYTHON_DEPS} )
"
RDEPEND="${RDEPEND}
	!!gnome-extra/nautilus-tracker-tags
"

function inotify_enabled() {
	if linux_config_exists; then
		if ! linux_chkconfig_present INOTIFY_USER; then
			ewarn "You should enable the INOTIFY support in your kernel."
			ewarn "Check the 'Inotify support for userland' under the 'File systems'"
			ewarn "option. It is marked as CONFIG_INOTIFY_USER in the config"
			die 'missing CONFIG_INOTIFY'
		fi
	else
		einfo "Could not check for INOTIFY support in your kernel."
	fi
}

pkg_setup() {
	linux-info_pkg_setup
	inotify_enabled

	python-any-r1_pkg_setup
}

src_configure() {
	gnome2_src_configure \
		--disable-static \
		--enable-introspection \
		--enable-journal \
		--enable-tracker-fts \
		--with-bash-completion-dir="$(get_bashcompdir)" \
		$(use_enable networkmanager network-manager) \
		$(use_enable stemmer libstemmer) \
		$(use_enable test functional-tests) \
		$(use_enable test unit-tests) \
		$(use_enable upower upower) \
		--with-unicode-support=$(usex unistring libunistring libicu) \
		VALAC="$(type -P false)"
}

src_test() {
	# G_MESSAGES_DEBUG, upstream bug #699401#c1
	virtx emake check TESTS_ENVIRONMENT="dbus-run-session" G_MESSAGES_DEBUG="all"
}
