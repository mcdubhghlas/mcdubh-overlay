# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Open-source game engine for everyone. No strings attached."
HOMEPAGE="https://www.redotengine.org/"
SRC_URI="https://github.com/Redot-Engine/redot-engine/releases/download/redot-4.3-beta.2/Redot_v4.3-beta.2_linux.x86_64.zip -> ${P}.zip"

LICENSE="
	MIT
	Apache-2.0 BSD Boost-1.0 CC0-1.0 Unlicense ZLIB
	gui? ( CC-BY-4.0 ) tools? ( OFL-1.1 )
"
SLOT="0"
KEYWORDS="~amd64"
IUSE="
	alsa +dbus debug deprecated +fontconfig +gui pulseaudio raycast
	speech test +theora +tools +udev +upnp +vulkan wayland +webp
"
RESTRICT="test"

RDEPEND="
	app-arch/brotli:=
	app-arch/zstd:=
	dev-games/recastnavigation:=
	dev-libs/icu:=
	dev-libs/libpcre2:=[pcre32]
	media-libs/freetype[brotli,harfbuzz]
	media-libs/harfbuzz:=[icu]
	media-libs/libogg
	media-libs/libpng:=
	media-libs/libvorbis
	<net-libs/mbedtls-3:=
	net-libs/wslay
	sys-libs/zlib:=
	media-libs/alsa-lib
	sys-apps/dbus
	media-libs/fontconfig
	media-libs/libglvnd
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libXinerama
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libxkbcommon
	media-libs/embree:4
	media-libs/vulkan-loader[X,wayland?]
	media-libs/libpulse
	media-libs/libtheora
	app-misc/ca-certificates
	virtual/udev
	media-libs/libwebp:=
"
DEPEND="
	${RDEPEND}
	x11-base/xorg-proto
"
BDEPEND="
	virtual/pkgconfig
	dev-util/wayland-scanner
"

src_unpack() {
	unpack ${P}.zip
	mkdir ${P}/
	mv Redot_v4.3-beta.1_linux.x86_64 ${P}/${P}
}

src_install() {
	newbin redot-bin-4.3_beta redot-bin
}


