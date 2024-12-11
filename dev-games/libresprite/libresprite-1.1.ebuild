# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Animated sprite editor & pixel art tool"
HOMEPAGE="https://libresprite.github.io/#!/"
SRC_URI="https://github.com/LibreSprite/LibreSprite/releases/download/v1.1/SOURCE.CODE.+.submodules.tar.gz -> ${P}.tar.gz" # We need +submodules

LICENSE="GPL-2 MIT BSD" # TODO: Check if sub-modules contain other LICENSES.
# third_party/EasyTab - https://unlicense.org
# third_party/duktape - MIT
# third_party/modp_b64 - BSD
# third_party/observable - MIT
# third_party/qoi - MIT
# third_party/simpleini - MIT
SLOT="0"
KEYWORDS="~amd64" # TODO: AFTER SUCCESS: test for ~x86 ~arm ~arm64 ~riscv"
IUSE="+sudo -doas" # TODO: Check out whats optional.
RESTRICT="test"

REQUIRED_USE="|| ( sudo doas )"

RDEPEND="
dev-build/cmake
net-misc/curl
media-libs/freetype
media-libs/giflib
dev-cpp/gtest
x11-libs/pixman
media-libs/libpng
media-libs/libsdl2
media-libs/sdl2-image[png,webp]
dev-libs/tinyxml2
net-libs/nodejs
dev-build/ninja
sys-libs/zlib
app-arch/libarchive
	sudo? ( app-admin/sudo )
	doas? ( app-admin/doas )
"

src_unpack() {
	mkdir ${P}/
	unpack ${P}.tar.gz
	mkdir build/
}

src_compile() {
	insinto build
	cmake -DCMAKE_INSTALL_PREFIX="/usr" -G Ninja ..
	ninja libresprite
}

src_install() {
	newbin bin/libresprite libresprite
	# PERM ISSUES for /usr/share/
	if use doas; then
		doas mkdir -p /usr/share/libresprite/data/
		doas mv bin/data/ /usr/share/libresprite/data
	fi
	if sudo; then
		sudo mkdir -p /usr/share/libresprite/data/
		sudo mv bin/data/ /usr/share/libresprite/data
	fi
}

pkg_postinst() {
	update-mime-database /usr/share/mime/
}

