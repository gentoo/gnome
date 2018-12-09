# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
VALA_USE_DEPEND="vapigen"
VALA_MIN_API_VERSION="0.36"

inherit gnome.org gnome2-utils linux-info meson readme.gentoo-r1 vala xdg
if [[ ${PV} = 9999 ]]; then
	inherit git-r3
	SRC_URI=""
	EGIT_REPO_URI="https://gitlab.gnome.org/GNOME/${GNOME_ORG_MODULE}"
fi

DESCRIPTION="Simple GNOME 3 application to access remote or virtual systems"
HOMEPAGE="https://wiki.gnome.org/Apps/Boxes"

LICENSE="LGPL-2"
SLOT="0"
IUSE="rdp"
if [[ ${PV} = 9999 ]]; then
	KEYWORDS=""
else
	KEYWORDS="~amd64" # qemu-kvm[spice] is 64bit-only
fi

# NOTE: sys-fs/* stuff is called via exec()
# FIXME: ovirt is not available in tree
# FIXME: qemu probably needs to depend on spice[smartcard]
#        directly with USE=spice
# gtk-vnc raised due to missing vala bindings in earlier ebuilds
COMMON_DEPEND="
	>=app-arch/libarchive-3:=
	>=dev-libs/glib-2.52:2
	>=x11-libs/gtk+-3.22.20:3
	>=net-libs/gtk-vnc-0.8.0-r1[gtk3(+),vala]
	>=sys-libs/libosinfo-1.1.0[vala]
	app-crypt/libsecret[vala]
	>=net-libs/libsoup-2.44:2.4
	virtual/libusb:1
	>=app-emulation/libvirt-glib-0.2.3[vala]
	>=dev-libs/libxml2-2.7.8:2
	>=net-misc/spice-gtk-0.32[gtk3(+),smartcard,usbredir,vala]
	>=app-misc/tracker-2:0=
	net-libs/webkit-gtk:4
	>=virtual/libgudev-165:=
	>=dev-libs/gobject-introspection-1:=
	rdp? ( net-misc/freerdp )
"
DEPEND="${COMMON_DEPEND}
	$(vala_depend)
	dev-util/itstool
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig

	>=dev-util/meson-0.47.0
"
RDEPEND="${COMMON_DEPEND}
	>=app-misc/tracker-miners-2[iso]
	app-emulation/spice[smartcard]
	>=app-emulation/libvirt-0.9.3[libvirtd,qemu]
	>=app-emulation/qemu-1.3.1[spice,smartcard,usbredir]
	sys-fs/mtools
"

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
	vala_src_prepare
	xdg_src_prepare
}

src_configure() {
	local emesonargs=(
		$(meson_use rdp)
		-Dovirt=false
	)
	meson_src_configure
}

src_install() {
	meson_src_install
	readme.gentoo_create_doc
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
	gnome2_icon_cache_update
	readme.gentoo_print_elog
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
	gnome2_icon_cache_update
}
