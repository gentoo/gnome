# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit gnome.org gnome2-utils meson multilib-minimal toolchain-funcs

DESCRIPTION="A thin layer of types for graphic libraries"
HOMEPAGE="https://developer.gnome.org/graphene/"

LICENSE="GPL-2"
SLOT="0"

IUSE="cpu_flags_arm_neon cpu_flags_x86_sse2 doc introspection gobject
	test vector"
REQUIRED_USE="test? ( introspection )
	introspection? ( gobject )"

KEYWORDS="~amd64"

RDEPEND="
	gobject? ( >=dev-libs/glib-2.30:2 )
	introspection? ( dev-libs/gobject-introspection )
"

DEPEND="
	doc? ( dev-util/gtk-doc )
"
# FIXME handle gcc-vector and other stuff

pkg_pretend() {
	if [[ ${MERGE_TYPE} != binary ]]  ; then
		if use vector; then
			tc-is-clang && die "gcc vector is not available for clang right?"
			use arm && die GCC vector intrinsics are disabled on ARM

			[[ $(gcc-major-version) -lt 4 ]] || \
											( [[ $(gcc-major-version) -eq 4 && $(gcc-minor-version) -le 9 ]] ) \
							&& die "GCC vector intrinsics are disabled on GCC prior to 4.9"
		fi

		if use cpu_flags_x86_sse2;then
		  [[ $(gcc-major-version) -lt 4 ]] || \
		                  ( [[ $(gcc-major-version) -eq 4 && $(gcc-minor-version) -le 2 ]] ) \
		          && die "Sorry, but gcc-4.2 and earlier won't work for sse2"
		fi
	fi
}

multilib_src_configure() {
	local emesonargs=(
		$(meson_use doc enable-gtk-doc)
		$(meson_use introspection enable-introspection)
		$(meson_use introspection enable-gobject-types)
		$(meson_use cpu_flags_arm_neon enable-arm-neon)
		$(meson_use cpu_flags_x86_sse2 enable-sse2)
		$(meson_use vector enable-gcc-vector)
	)
	meson_src_configure
}

multilib_src_compile() {
	meson_src_compile
}

multilib_src_test() {
	meson_src_test
}

multilib_src_install() {
	meson_src_install
}

pkg_postinst() {
	multilib_pkg_postinst() {
		gnome2_giomodule_cache_update \
			|| die "Update GIO modules cache failed (for ${ABI})"
	}
	multilib_foreach_abi multilib_pkg_postinst
}

pkg_postrm() {
	multilib_pkg_postrm() {
		gnome2_giomodule_cache_update \
			|| die "Update GIO modules cache failed (for ${ABI})"
	}
	multilib_foreach_abi multilib_pkg_postrm
}
