# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# @ECLASS: xdg.eclass
# @MAINTAINER:
# freedesktop-bugs@gentoo.org
# @AUTHOR:
# Original author: Gilles Dartiguelongue <eva@gentoo.org>
# @BLURB: Provides phases for XDG compliant packages.
# @DESCRIPTION:
# Utility eclass to update the desktop and shared mime info as laid
# out in the freedesktop specs & implementations

inherit xdg-utils

case "${EAPI:-0}" in
	4|5)
		EXPORT_FUNCTIONS src_prepare pkg_preinst pkg_postinst pkg_postrm
		;;
	*) die "EAPI=${EAPI} is not supported" ;;
esac

DEPEND="
	dev-util/desktop-file-utils
	x11-misc/shared-mime-info
"

# @FUNCTION: xdg_src_prepare
# @DESCRIPTION:
# Prepare sources to work with XDG standards.
xdg_src_prepare() {
	# Prepare XDG base directories
	export XDG_DATA_HOME="${T}/.local/share"
	export XDG_CONFIG_HOME="${T}/.config"
	export XDG_CACHE_HOME="${T}/.cache"
	export XDG_RUNTIME_DIR="${T}/run"
	mkdir -p "${XDG_DATA_HOME}" "${XDG_CONFIG_HOME}" "${XDG_CACHE_HOME}" \
		"${XDG_RUNTIME_DIR}"
	# This directory needs to be owned by the user, and chmod 0700
	# http://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html
	chmod 0700 "${XDG_RUNTIME_DIR}"
}

# @FUNCTION: xdg_pkg_preinst
# @DESCRIPTION:
# Finds .desktop and mime info files for later handling in pkg_postinst
xdg_pkg_preinst() {
	xdg_desktopfiles_savelist
	xdg_mimeinfo_savelist
}

# @FUNCTION: xdg_pkg_postinst
# @DESCRIPTION:
# Handle desktop and mime info database updates.
xdg_pkg_postinst() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}

# @FUNCTION: xdg_pkg_postrm
# @DESCRIPTION:
# Handle desktop and mime info database updates.
xdg_pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}

