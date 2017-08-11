# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
VALA_USE_DEPEND="vapigen"
VALA_MIN_API_VERSION="0.28"

inherit gnome2 linux-info readme.gentoo-r1 vala
if [[ ${PV} = 9999 ]]; then
	inherit gnome2-live
fi

DESCRIPTION="Simple GNOME 3 application to access remote or virtual systems"
HOMEPAGE="https://wiki.gnome.org/Apps/Boxes"

LICENSE="LGPL-2"
SLOT="0"
IUSE="bindist"
if [[ ${PV} = 9999 ]]; then
	KEYWORDS=""
else
	KEYWORDS="~amd64" # qemu-kvm[spice] is 64bit-only
fi

# NOTE: sys-fs/* stuff is called via exec()
# FIXME: ovirt is not available in tree
RDEPEND="
	>=app-arch/libarchive-3:=
	>=dev-libs/glib-2.38:2
	>=dev-libs/gobject-introspection-0.9.6:=
	>=dev-libs/libxml2-2.7.8:2
	>=sys-libs/libosinfo-0.2.12
	>=app-emulation/qemu-1.3.1[spice,smartcard,usbredir]
	>=app-emulation/libvirt-0.9.3[libvirtd,qemu]
	>=app-emulation/libvirt-glib-0.2.3
	>=x11-libs/gtk+-3.19.8:3
	>=net-libs/gtk-vnc-0.4.4[gtk3]
	app-crypt/libsecret
	app-emulation/spice[smartcard]
	>=net-misc/spice-gtk-0.32[gtk3,smartcard,usbredir]
	virtual/libusb:1

	>=app-misc/tracker-0.16:0=[iso]

	>=sys-apps/util-linux-2.20
	>=net-libs/libsoup-2.38:2.4

	sys-fs/mtools
	>=virtual/libgudev-165:=
	!bindist? ( gnome-extra/gnome-boxes-nonfree )
"
DEPEND="${RDEPEND}
	app-text/yelp-tools
	>=dev-util/intltool-0.40
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
"

if [[ ${PV} = 9999 ]]; then
	DEPEND="${DEPEND}
		$(vala_depend)
		sys-libs/libosinfo[introspection,vala]
		app-emulation/libvirt-glib[introspection,vala]
		net-libs/gtk-vnc[introspection,vala]
		net-misc/spice-gtk[introspection,vala]
		net-libs/rest:0.7[introspection]"
fi

DISABLE_AUTOFORMATTING="yes"
DOC_CONTENTS="Before running gnome-boxes, you will need to load the KVM modules.
If you have an Intel Processor, run:
# modprobe kvm-intel

If you have an AMD Processor, run:
# modprobe kvm-amd"

pkg_pretend() {
	linux-info_get_any_version

	if linux_config_exists; then
		if ! { linux_chkconfig_present KVM_AMD || \
			linux_chkconfig_present KVM_INTEL; }; then
			ewarn "You need KVM support in your kernel to use GNOME Boxes!"
		fi
	fi
}

src_prepare() {
	# Do not change CFLAGS, wondering about VALA ones but appears to be
	# needed as noted in configure comments below
	sed 's/CFLAGS="$CFLAGS -O0 -ggdb3"//' -i configure.ac || die

	vala_src_prepare
	gnome2_src_prepare
}

src_configure() {
	# debug needed for splitdebug proper behavior (cardoe), bug #????
	gnome2_src_configure \
		--enable-debug \
		--disable-strict-cc \
		--disable-ovirt
}

src_install() {
	gnome2_src_install
	readme.gentoo_create_doc
}

pkg_postinst() {
	gnome2_pkg_postinst
	readme.gentoo_print_elog
}
