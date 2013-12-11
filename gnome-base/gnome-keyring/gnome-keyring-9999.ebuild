# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
GCONF_DEBUG="yes" # Not gnome macro but similar
GNOME2_LA_PUNT="yes"

inherit fcaps gnome2 pam versionator virtualx
if [[ ${PV} = 9999 ]]; then
	inherit gnome2-live
fi

DESCRIPTION="Password and keyring managing daemon"
HOMEPAGE="http://live.gnome.org/GnomeKeyring"

LICENSE="GPL-2+ LGPL-2+"
SLOT="0"
IUSE="+caps debug pam selinux"
if [[ ${PV} = 9999 ]]; then
	KEYWORDS=""
else
	KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux ~sparc-solaris ~x86-solaris"
fi

RDEPEND="
	>=app-crypt/gcr-3.5.3:=[gtk]
	>=dev-libs/glib-2.32.0:2
	app-misc/ca-certificates
	>=dev-libs/libgcrypt-1.2.2:=
	>=sys-apps/dbus-1.1.1
	caps? ( sys-libs/libcap-ng )
	pam? ( virtual/pam )
"
DEPEND="${RDEPEND}
	app-text/docbook-xml-dtd:4.3
	dev-libs/libxslt
	>=dev-util/intltool-0.35
	sys-devel/gettext
	virtual/pkgconfig
"
PDEPEND=">=gnome-base/libgnome-keyring-3.1.92"

src_prepare() {
	# Disable stupid CFLAGS
	sed -e 's/CFLAGS="$CFLAGS -g"//' \
		-e 's/CFLAGS="$CFLAGS -O0"//' \
		-i configure.ac configure || die

	gnome2_src_prepare
}

src_configure() {
	gnome2_src_configure \
		$(use_with caps libcap-ng) \
		$(use_enable pam) \
		$(use_with pam pam-dir $(getpam_mod_dir)) \
		$(use_enable selinux) \
		--enable-doc \
		--enable-ssh-agent \
		--enable-gpg-agent
}

src_test() {
	 # FIXME: this should be handled at eclass level
	 "${EROOT}${GLIB_COMPILE_SCHEMAS}" --allow-any-name "${S}/schema" || die

	 unset DBUS_SESSION_BUS_ADDRESS
	 GSETTINGS_SCHEMA_DIR="${S}/schema" Xemake check
}

pkg_postinst() {
	fcaps cap_ipc_lock usr/bin/gnome-keyring-daemon
	gnome2_pkg_postinst
}
