# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

# PackageKit supports 3.2+, but entropy and portage backends are untested
# Future note: use --enable-python3
PYTHON_COMPAT=( python2_7 )

inherit bash-completion-r1 eutils multilib nsplugins python-single-r1 systemd

MY_PN="PackageKit"
MY_P=${MY_PN}-${PV}

DESCRIPTION="Manage packages in a secure way using a cross-distro and cross-architecture API"
HOMEPAGE="http://www.packagekit.org/"
SRC_URI="http://www.freedesktop.org/software/${MY_PN}/releases/${MY_P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~mips ~ppc ~ppc64 ~x86"
IUSE="bash-completion connman cron command-not-found +introspection networkmanager nsplugin entropy systemd test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

CDEPEND="
	bash-completion? ( >=app-shells/bash-completion-2.0 )
	connman? ( net-misc/connman )
	introspection? ( >=dev-libs/gobject-introspection-0.9.9[${PYTHON_USEDEP}] )
	networkmanager? ( >=net-misc/networkmanager-0.6.4 )
	nsplugin? (
		>=dev-libs/nspr-4.8
		x11-libs/cairo
		>=x11-libs/gtk+-2.14.0:2
		x11-libs/pango
	)
	dev-db/sqlite:3
	>=dev-libs/dbus-glib-0.74
	>=dev-libs/glib-2.32.0:2[${PYTHON_USEDEP}]
	>=sys-auth/polkit-0.98
	>=sys-apps/dbus-1.3.0
	${PYTHON_DEPS}
"
DEPEND="${CDEPEND}
	dev-util/gtk-doc-am
	nsplugin? ( >=net-misc/npapi-sdk-0.27 )
	systemd? ( >=sys-apps/systemd-204 )
	dev-libs/libxslt[${PYTHON_USEDEP}]
	>=dev-util/intltool-0.35.0
	virtual/pkgconfig
	sys-devel/gettext
"
RDEPEND="${CDEPEND}
	entropy? ( >=sys-apps/entropy-234[${PYTHON_USEDEP}] )
	>=app-portage/layman-1.2.3[${PYTHON_USEDEP}]
	>=sys-apps/portage-2.2[${PYTHON_USEDEP}]
"

S="${WORKDIR}/${MY_P}"

RESTRICT="test"

src_configure() {
	econf \
		--disable-gstreamer-plugin \
		--disable-gtk-doc \
		--disable-gtk-module \
		--disable-schemas-compile \
		--disable-static \
		--enable-man-pages \
		--enable-nls \
		--enable-portage \
		--localstatedir=/var \
		$(use_enable bash-completion) \
		$(use_enable command-not-found) \
		$(use_enable connman) \
		$(use_enable cron) \
		$(use_enable entropy) \
		$(use_enable introspection) \
		$(use_enable networkmanager) \
		$(use_enable nsplugin browser-plugin) \
		$(use_enable systemd) \
		$(use_enable test local) \
		$(use_enable test daemon-tests) \
		$(systemd_with_unitdir)
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	prune_libtool_files --all

	dodoc AUTHORS MAINTAINERS NEWS README || die "dodoc failed"
	dodoc ChangeLog || die "dodoc failed"

	if use nsplugin; then
		dodir "/usr/$(get_libdir)/${PLUGINS_DIR}"
		mv "${D}/usr/$(get_libdir)/mozilla/plugins"/* \
			"${D}/usr/$(get_libdir)/${PLUGINS_DIR}/" || die
	fi
}
