# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME2_LA_PUNT="yes"
PYTHON_COMPAT=( python{3_4,3_5,3_6} )

inherit bash-completion-r1 eutils gnome2 linux-info multilib python-any-r1 vala versionator virtualx

DESCRIPTION="A tagging metadata database, search tool and indexer"
HOMEPAGE="https://wiki.gnome.org/Projects/Tracker"

LICENSE="GPL-2+ LGPL-2.1+"
SLOT="0/2.0"
IUSE="doc elibc_glibc journal networkmanager stemmer upower unistring test"

KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~ia64 ~ppc ~ppc64 ~sparc ~x86"

# glibc-2.12 needed for SCHED_IDLE (see bug #385003)
# seccomp is automagic, though we want to use it whenever possible (linux)
# FIXME libsoup automagic
RDEPEND="
	>=dev-db/sqlite-3.20:=
	>=dev-libs/glib-2.44:2
	>=dev-libs/gobject-introspection-0.9.5:=
	>=dev-libs/json-glib-1.0
	>=dev-libs/libxml2-2.6:2
	>=net-libs/libsoup-2.40:2.4
	>=sys-apps/dbus-1.3.1
	sys-apps/util-linux
	>=app-text/libgepub-0.5.2
	elibc_glibc? ( >=sys-libs/glibc-2.12 )
	networkmanager? ( >=net-misc/networkmanager-0.8 )
	stemmer? ( dev-libs/snowball-stemmer )
	unistring? ( dev-libs/libunistring )
	!unistring? ( >=dev-libs/icu-4.8.1.1:= )
"
DEPEND="${RDEPEND}
	$(vala_depend)
	dev-util/gdbus-codegen
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
	doc? ( dev-util/gtk-doc-am )
	test? ( ${PYTHON_DEPS} )
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

src_prepare() {
	gnome2_src_prepare
	vala_src_prepare
}
#FIXME what to do with systemd user services
#FIXME fts5 disabling is broken for meson_use
#FIXME gcov useflag
src_configure() {
	gnome2_src_configure \
		--enable-introspection \
	  	--enable-tracker-fts \
	  	--with-bash-completion-dir="$(get_bashcompdir)" \
	  	$(use_enable journal) \
	  	$(use_enable networkmanager network-manager) \
	  	$(use_enable stemmer libstemmer) \
	  	$(use_enable test functional-tests) \
	  	$(use_enable test unit-tests) \
	  	$(use_enable upower upower) \
	  	$(use_with !unistring icu) \
	  	$(use_with unistring unistring)
}

src_test() {
	# G_MESSAGES_DEBUG, upstream bug #699401#c1
	virtx emake check TESTS_ENVIRONMENT="dbus-run-session" G_MESSAGES_DEBUG="all"
}
