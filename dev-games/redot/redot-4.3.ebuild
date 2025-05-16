# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Open-source game engine for everyone. No strings attached."
HOMEPAGE="https://www.redotengine.org/"
#SRC_URI="https://github.com/Redot-Engine/redot-engine/archive/refs/tags/${P}-stable.tar.gz -> ${P}.tar.gz"
SRC_URI="https://mcdubh.org/redot/redot-4.3-stable.tar.gz -> ${P}.tar.gz"

LICENSE="
	MIT
	Apache-2.0 BSD Boost-1.0 CC0-1.0 Unlicense ZLIB
	gui? ( CC-BY-4.0 ) tools? ( OFL-1.1 )
"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm ~arm64"
IUSE="
	alsa +dbus debug deprecated +fontconfig +gui pulseaudio raycast
	speech test +theora +tools +udev +upnp +vulkan wayland +webp
"
REQUIRED_USE="wayland? ( gui )"
RESTRICT="test"

RDEPEND="
	app-arch/brotli:=
	app-arch/zstd:=
	dev-games/recastnavigation:=
	dev-build/scons:=
	dev-libs/icu:=
	dev-libs/libpcre2:=[pcre32]
	media-libs/freetype[brotli,harfbuzz]
	media-libs/harfbuzz:=[icu]
	media-libs/glu:=
	media-libs/libogg
	media-libs/libpng:=
	media-libs/libvorbis
	<net-libs/mbedtls-3:=
	net-libs/wslay
	sys-libs/zlib:=
	alsa? ( media-libs/alsa-lib )
	dbus? ( sys-apps/dbus )
	fontconfig? ( media-libs/fontconfig )
	gui? (
		media-libs/libglvnd
		x11-libs/libX11
		x11-libs/libXcursor
		x11-libs/libXext
		x11-libs/libXi
		x11-libs/libXinerama
		x11-libs/libXrandr
		x11-libs/libXrender
		x11-libs/libxkbcommon
		tools? ( raycast? ( media-libs/embree:4 ) )
		vulkan? ( media-libs/vulkan-loader[X,wayland?] )
	)
	pulseaudio? ( media-libs/libpulse )
	speech? ( app-accessibility/speech-dispatcher )
	theora? ( media-libs/libtheora )
	tools? ( app-misc/ca-certificates )
	udev? ( virtual/udev )
	wayland? (
		dev-libs/wayland
		gui-libs/libdecor
	)
	webp? ( media-libs/libwebp:= )
"
DEPEND="
	${RDEPEND}
	gui? ( x11-base/xorg-proto )
	tools? ( test? ( dev-cpp/doctest ) )
"
BDEPEND="
	virtual/pkgconfig
	wayland? ( dev-util/wayland-scanner )
"
PATCHES=(
	"${FILESDIR}"/redot-4.3-version.patch
)

src_unpack() {
	unpack ${P}.tar.gz
	mv redot-engine*/ ${P}/
}


src_compile() {
	local -x BUILD_NAME=gentoo # replaces "custom_build" in version string

	#filter-lto #921017

	local esconsargs=(
		#AR="$(tc-getAR)" CC="$(tc-getCC)" CXX="$(tc-getCXX)"

		progress=no
		verbose=yes

		use_sowrap=no

		alsa=$(usex alsa)
		dbus=$(usex dbus)
		deprecated=$(usex deprecated)
		execinfo=no # not packaged, disables crash handler if non-glibc
		fontconfig=$(usex fontconfig)
		opengl3=$(usex gui)
		pulseaudio=$(usex pulseaudio)
		speechd=$(usex speech)
		udev=$(usex udev)
		use_volk=no # unnecessary when linking directly to libvulkan
		vulkan=$(usex gui $(usex vulkan))
		wayland=$(usex wayland)
		# TODO: retry to add optional USE=X, wayland support is new
		# and gui build is not well wired to handle USE="-X wayland" yet
		x11=$(usex gui)

		system_certs_path="${EPREFIX}"/etc/ssl/certs/ca-certificates.crt

		# platform/*/detect.py uses builtin_* switches to check if need
		# to link with system libraries, but many ignore whether the dep
		# is actually used, so "enable" deleted builtins on disabled deps
		builtin_brotli=no
		builtin_certs=no
		builtin_clipper2=yes # not packaged
		builtin_embree=$(usex !gui yes $(usex !tools yes $(usex !raycast)))
		builtin_enet=yes # bundled copy is patched for IPv6+DTLS support
		builtin_freetype=no
		builtin_glslang=yes #879111 (for now, may revisit if more stable)
		builtin_graphite=no
		builtin_harfbuzz=no
		builtin_icu4c=no
		builtin_libogg=no
		builtin_libpng=no
		builtin_libtheora=$(usex !theora)
		builtin_libvorbis=no
		builtin_libwebp=$(usex !webp)
		builtin_mbedtls=no
		builtin_miniupnpc=yes #934044 (for now, should revisit)
		builtin_msdfgen=yes # not wired for unbundling nor packaged
		builtin_openxr=yes # not packaged
		builtin_pcre2=no
		builtin_recastnavigation=no
		builtin_rvo2=yes # bundled copy has godot-specific changes
		builtin_squish=yes # ^ likewise, may not be safe to unbundle
		builtin_wslay=no
		builtin_xatlas=yes # not wired for unbundling nor packaged
		builtin_zlib=no
		builtin_zstd=no
		# (more is bundled in third_party/ but they lack builtin_* switches)

		# modules with optional dependencies, "possible" to disable more but
		# gets messy and breaks all sorts of features (expected enabled)
		module_mono_enabled=no # unhandled
		# note raycast is only enabled on amd64+arm64, see raycast/config.py
		module_raycast_enabled=$(usex gui $(usex tools $(usex raycast)))
		module_theora_enabled=$(usex theora)
		module_upnp_enabled=$(usex upnp)
		module_webp_enabled=$(usex webp)

		# let *FLAGS handle these
		debug_symbols=no
		lto=none
		optimize=custom
		use_static_cpp=no
	)

	esconsargs+=(
		target=$(usex tools editor template_$(usex debug{,} release))
		dev_build=$(usex debug)

		# harmless but note this bakes in --test in the final binary
		tests=$(usex tools $(usex test))
	)

	scons "${esconsargs[@]}"
}

src_install() {
	# suffix varies depending on arch/features, use wildcard to simplify
	newbin bin/redot* redot

	# Install manpages to /usr/share/man
	# Manpages blocked until PR #804 is added in.
	#doman misc/dist/linux/godot.6
	# Install doc files to /usr/share/doc/${PF}
	dodoc AUTHORS.md CHANGELOG.md DONORS.md README.md

	if use gui; then
		# install selected icon as redot.svg
		newicon icon.svg redot.svg
		# Install .desktop to /usr/share/applications
		domenu misc/dist/linux/org.redotengine.Redot.desktop

		# cd
		insinto /usr/share/metainfo
		# install file
		doins misc/dist/linux/org.redotengine.Redot.appdata.xml

		insinto /usr/share/mime/application
		doins misc/dist/linux/org.redotengine.Redot.xml
	fi
}

pkg_postinst() {
	update-mime-database /usr/share/mime/
}

