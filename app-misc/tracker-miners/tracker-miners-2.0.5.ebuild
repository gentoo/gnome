# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
GNOME2_LA_PUNT="yes"
PYTHON_COMPAT=( python3_{4,5,6} )

inherit gnome2 python-any-r1

DESCRIPTION="Applications, RSS and filesystem miners for tracker"
HOMEPAGE="https://wiki.gnome.org/Projects/Tracker"

LICENSE="GPL-2+ LGPL-2.1+"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE="cue elibc_glibc exif ffmpeg flac gif gsf gstreamer iptc +iso +jpeg libav +miner-fs mp3 pdf playlist raw rss seccomp test +tiff upnp-av upower vorbis xml xmp xps"

REQUIRED_USE="
	?? ( gstreamer ffmpeg )
	cue? ( gstreamer )
	upnp-av? ( gstreamer )
	!miner-fs? ( !cue !exif !flac !gif !gsf !iptc !iso !jpeg !mp3 !pdf !playlist !raw !tiff !vorbis !xml !xmp !xps )
"

# glibc-2.12 needed for SCHED_IDLE (see bug #385003)
# seccomp is automagic, though we want to use it whenever possible (linux)
RDEPEND="
	>=sys-apps/dbus-1.3.1
	>=dev-libs/glib-2.44:2
	>=media-libs/libpng-1.2:0=
	>=app-misc/tracker-1.99:0=
	>=app-i18n/enca-1.9
	>=dev-libs/icu-4.8.1.1:=

	cue? ( media-libs/libcue )
	elibc_glibc? ( >=sys-libs/glibc-2.12 )
	exif? ( >=media-libs/libexif-0.6 )
	ffmpeg? (
		libav? ( media-video/libav:= )
		!libav? ( media-video/ffmpeg:0= )
	)
	flac? ( >=media-libs/flac-1.2.1 )
	gif? ( media-libs/giflib:= )
	gsf? ( >=gnome-extra/libgsf-1.14.24 )
	gstreamer? (
		media-libs/gstreamer:1.0
		media-libs/gst-plugins-base:1.0 )
	iptc? ( media-libs/libiptcdata )
	iso? ( >=sys-libs/libosinfo-0.2.9:= )
	jpeg? ( virtual/jpeg:0 )
	mp3? ( >=media-libs/taglib-1.6 )
	pdf? (
		>=x11-libs/cairo-1:=
		>=app-text/poppler-0.16[cairo,utils]
	)
	playlist? ( >=dev-libs/totem-pl-parser-3 )
	rss? ( >=net-libs/libgrss-0.7:0 )
	seccomp? ( >=sys-libs/libseccomp-2.0 )
	tiff? ( media-libs/tiff:0 )
	upnp-av? ( >=media-libs/gupnp-dlna-0.9.4:2.0 )
	upower? ( >=sys-power/upower-0.9 )
	vorbis? ( >=media-libs/libvorbis-0.22 )
	xml? ( >=dev-libs/libxml2-2.6:2 )
	xmp? ( >=media-libs/exempi-2.1 )
	xps? ( app-text/libgxps )
	!gstreamer? ( !ffmpeg? ( || ( media-video/totem media-video/mplayer ) ) )
"
DEPEND="${RDEPEND}
	dev-util/gdbus-codegen
	>=dev-util/intltool-0.40.0
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
	test? (
		${PYTHON_DEPS}
		>=sys-apps/dbus-1.3.1[X]
	)
"

pkg_setup() {
	use test && python-any-r1_pkg_setup
}

src_configure() {
	local myconf=""

	if use gstreamer ; then
		myconf="${myconf} --enable-generic-media-extractor=gstreamer"
		if use upnp-av; then
			myconf="${myconf} --with-gstreamer-backend=gupnp-dlna"
		else
			myconf="${myconf} --with-gstreamer-backend=discoverer"
		fi
	elif use ffmpeg ; then
		myconf="${myconf} --enable-generic-media-extractor=libav"
	else
		myconf="${myconf} --enable-generic-media-extractor=external"
	fi

	# libstemmer has no effect in this package
	# icu is actually optional if enca is installed, deal with this later
	gnome2_src_configure \
		--disable-static \
		--disable-hal \
		--disable-libstemmer \
		--enable-abiword \
		--enable-icu-charset-detection \
		--enable-dvi \
		--enable-enca \
		--enable-guarantee-metadata \
		--enable-icon \
		--enable-libpng \
		--enable-miner-apps \
		--enable-ps \
		--enable-text \
		--enable-tracker-writeback \
		$(use_enable cue libcue) \
		$(use_enable exif libexif) \
		$(use_enable flac libflac) \
		$(use_enable gif libgif) \
		$(use_enable gsf libgsf) \
		$(use_enable iptc libiptcdata) \
		$(use_enable iso libosinfo) \
		$(use_enable jpeg libjpeg) \
		$(use_enable miner-fs) \
		$(use_enable mp3 taglib) \
		$(use_enable mp3) \
		$(use_enable pdf poppler) \
		$(use_enable playlist) \
		$(use_enable rss miner-rss) \
		$(use_enable test functional-tests) \
		$(use_enable test unit-tests) \
		$(use_enable tiff libtiff) \
		$(use_enable upower upower) \
		$(use_enable vorbis libvorbis) \
		$(use_enable xml libxml2) \
		$(use_enable xmp exempi) \
		$(use_enable xps libgxps) \
		${myconf}
}

src_test() {
	# G_MESSAGES_DEBUG, upstream bug #699401#c1
	virtx emake check TESTS_ENVIRONMENT="dbus-run-session" G_MESSAGES_DEBUG="all"
}
