#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${ROOT_DIR}/build-qt6"

echo "[LightlyShaders] Building Qt6/KF6 (Plasma 6.x)"

install_dependencies() {
	if command -v apt-get >/dev/null 2>&1; then
		echo "[LightlyShaders] Detected Debian/Ubuntu. Installing dependencies automatically..."
		sudo apt-get update
		sudo apt-get install -y \
			cmake \
			extra-cmake-modules \
			qt6-base-dev \
			qt6-base-dev-tools \
			qt6-declarative-dev \
			kwin-dev \
			libkdecorations3-dev \
			libdrm-dev \
			libkf6config-dev \
			libkf6coreaddons-dev \
			libkf6windowsystem-dev \
			libkf6configwidgets-dev \
			libkf6crash-dev \
			libkf6globalaccel-dev \
			libkf6i18n-dev \
			libkf6kio-dev \
			libkf6service-dev \
			libkf6notifications-dev \
			libkf6widgetsaddons-dev \
			libkf6guiaddons-dev \
			libkf6kcmutils-dev \
			libxcb-composite0-dev \
			libxcb-randr0-dev \
			libxcb-shm0-dev \
			libxcb-damage0-dev \
			libxcb-keysyms1-dev \
			libxcb-image0-dev \
			libxcb-icccm4-dev \
			libxcb-util-dev \
			libxcb-xkb-dev
	elif command -v pacman >/dev/null 2>&1; then
		echo "[LightlyShaders] Detected Arch Linux. Installing dependencies automatically..."
		sudo pacman -Syu --needed --noconfirm \
			cmake \
			extra-cmake-modules \
			kwin \
			kdecoration \
			qt6-base \
			qt6-declarative \
			libdrm \
			libxcb \
			xcb-util \
			xcb-util-image \
			xcb-util-keysyms \
			xcb-util-wm \
			git
	elif command -v dnf >/dev/null 2>&1; then
		echo "[LightlyShaders] Detected Fedora. Installing dependencies automatically..."
		sudo dnf install -y \
			cmake \
			extra-cmake-modules \
			qt6-qtbase-devel \
			qt6-qtdeclarative-devel \
			kwin-devel \
			kdecoration-devel \
			libdrm-devel \
			libxcb-devel \
			xcb-util-devel \
			xcb-util-image-devel \
			xcb-util-keysyms-devel \
			xcb-util-wm-devel \
			kf6-kconfig-devel \
			kf6-kcoreaddons-devel \
			kf6-kwindowsystem-devel \
			kf6-kconfigwidgets-devel \
			kf6-kcrash-devel \
			kf6-kglobalaccel-devel \
			kf6-ki18n-devel \
			kf6-kio-devel \
			kf6-kservice-devel \
			kf6-knotifications-devel \
			kf6-kwidgetsaddons-devel \
			kf6-kguiaddons-devel \
			kf6-kcmutils-devel
	else
		echo "[LightlyShaders] Package manager not recognized. Please install dependencies manually."
	fi
}

install_dependencies

cmake -S "${ROOT_DIR}" -B "${BUILD_DIR}" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
cmake --build "${BUILD_DIR}" -j"$(nproc)"
sudo cmake --install "${BUILD_DIR}"

echo "[LightlyShaders] Qt6 installation finished."
