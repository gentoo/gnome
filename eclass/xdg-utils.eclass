# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: xdg-utils.eclass
# @MAINTAINER:
# gnome@gentoo.org
# @AUTHOR:
# Original author: Gilles Dartiguelongue <eva@gentoo.org>
# @BLURB: Auxiliary functions commonly used by XDG compliant packages.
# @DESCRIPTION:
# This eclass provides a set of auxiliary functions needed by most XDG
# compliant packages.
# It provides XDG stack related functions such as:
#  * XDG .desktop files cache management
#  * XDG mime information database management

case "${EAPI:-0}" in
	4|5) ;;
	*) die "EAPI=${EAPI} is not supported" ;;
esac

# @ECLASS-VARIABLE: DESKTOP_DATABASE_UPDATE_BIN
# @INTERNAL
# @DESCRIPTION:
# Path to update-desktop-database
: ${DESKTOP_DATABASE_UPDATE_BIN:="/usr/bin/update-desktop-database"}

# @ECLASS-VARIABLE: DESKTOP_DATABASE_DIR
# @INTERNAL
# @DESCRIPTION:
# Directory where .desktop files database is stored
: ${DESKTOP_DATABASE_DIR="/usr/share/applications"}

# @ECLASS-VARIABLE: MIMEINFO_DATABASE_UPDATE_BIN
# @INTERNAL
# @DESCRIPTION:
# Path to update-desktop-database
: ${MIMEINFO_DATABASE_UPDATE_BIN:="/usr/bin/update-mime-database"}

# @ECLASS-VARIABLE: MIMEINFO_DATABASE_DIR
# @INTERNAL
# @DESCRIPTION:
# Directory where .desktop files database is stored
: ${MIMEINFO_DATABASE_DIR:="/usr/share/mime"}

# @FUNCTION: xdg_desktopfiles_savelist
# @DESCRIPTION:
# Find the .desktop files about to be installed and save their location
# in the XDG_ECLASS_DESKTOPFILES environment variable.
# This function should be called from pkg_preinst.
xdg_desktopfiles_savelist() {
	pushd "${D}" &> /dev/null
	export XDG_ECLASS_DESKTOPFILES=$(find 'usr/share/applications' -type f 2> /dev/null)
	popd &> /dev/null
}

# @FUNCTION: fdo-xdg_desktop_database_update
# @DESCRIPTION:
# Updates the .desktop files database.
# Generates a list of mimetypes linked to applications that can handle them
xdg_desktop_database_update() {
	local updater="${EROOT}${DESKTOP_DATABASE_UPDATE_BIN}"

	if [[ ! -x "${updater}" ]] ; then
		debug-print "${updater} is not executable"
		return
	fi

	if [[ -z "${XDG_ECLASS_DESKTOPFILES}" ]]; then
		debug-print "No .desktop files to add to database"
		return
	fi

	ebegin "Updating .desktop files database ..."
	"${updater}" -q "${EROOT}${DESKTOP_DATABASE_DIR}"
	eend $?
}

# @FUNCTION: xdg_mimeinfo_savelist
# @DESCRIPTION:
# Find the mime information files about to be installed and save their location
# in the XDG_ECLASS_MIMEINFOFILES environment variable.
# This function should be called from pkg_preinst.
xdg_mimeinfo_savelist() {
	pushd "${D}" &> /dev/null
	export XDG_ECLASS_MIMEINFOFILES=$(find 'usr/share/mime' -type f 2> /dev/null)
	popd &> /dev/null
}

# @FUNCTION: xdg_mimeinfo_database_update
# @DESCRIPTION:
# Update the mime database.
# Creates a general list of mime types from several sources
xdg_mimeinfo_database_update() {
	local updater="${EROOT}${MIMEINFO_DATABASE_UPDATE_BIN}"

	if [[ ! -x "${updater}" ]] ; then
		debug-print "${updater} is not executable"
		return
	fi

	if [[ -z "${XDG_ECLASS_MIMEINFOFILES}" ]]; then
		debug-print "No mime info files to add to database"
		return
	fi

	ebegin "Updating shared mime info database ..."
	"${updater}" "${EROOT}${MIMEINFO_DATABASE_DIR}"
	eend $?
}
