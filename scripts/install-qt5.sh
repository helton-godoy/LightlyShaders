#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
QT5_TAG="v2.2.1"
WORKTREE_DIR="${ROOT_DIR}/.worktrees/qt5-${QT5_TAG}"
BUILD_DIR="${WORKTREE_DIR}/build"

install_dependencies() {
	if command -v apt-get >/dev/null 2>&1; then
		echo "[LightlyShaders] Detected Debian/Ubuntu. Installing dependencies automatically..."
		sudo apt-get update
		sudo apt-get install -y \
			cmake \
			extra-cmake-modules \
			qtbase5-dev \
			qtdeclarative5-dev \
			kwin-dev \
			libkdecorations2-dev \
			libdrm-dev \
			libkf5config-dev \
			libkf5coreaddons-dev \
			libkf5windowsystem-dev \
			libkf5configwidgets-dev \
			libkf5crash-dev \
			libkf5globalaccel-dev \
			libkf5i18n-dev \
			libkf5kio-dev \
			libkf5service-dev \
			libkf5notifications-dev \
			libkf5widgetsaddons-dev \
			libkf5guiaddons-dev \
			libkf5kcmutils-dev \
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
			kwin5 \
			kdecoration \
			qt5-base \
			qt5-declarative \
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
			qt5-qtbase-devel \
			qt5-qtdeclarative-devel \
			kwin-devel \
			kdecoration-devel \
			libdrm-devel \
			libxcb-devel \
			xcb-util-devel \
			xcb-util-image-devel \
			xcb-util-keysyms-devel \
			xcb-util-wm-devel \
			kf5-kconfig-devel \
			kf5-kcoreaddons-devel \
			kf5-kwindowsystem-devel \
			kf5-kconfigwidgets-devel \
			kf5-kcrash-devel \
			kf5-kglobalaccel-devel \
			kf5-ki18n-devel \
			kf5-kio-devel \
			kf5-kservice-devel \
			kf5-knotifications-devel \
			kf5-kwidgetsaddons-devel \
			kf5-kguiaddons-devel \
			kf5-kcmutils-devel
	else
		echo "[LightlyShaders] Package manager not recognized. Please install dependencies manually."
	fi
}

install_dependencies

echo "[LightlyShaders] Preparing Qt5/KF5 (Plasma 5.27) worktree from ${QT5_TAG}"

mkdir -p "${ROOT_DIR}/.worktrees"

if [ ! -d "${WORKTREE_DIR}" ]; then
	git -C "${ROOT_DIR}" worktree add "${WORKTREE_DIR}" "${QT5_TAG}"
fi

set +o pipefail
LIBKWIN_PATH="$(ldconfig -p | grep -E 'libkwin\.so\.5 \(' | head -n1 | awk '{print $NF}')"
set -o pipefail
if [ -n "${LIBKWIN_PATH}" ]; then
	LIBKWIN_DIR="$(dirname "${LIBKWIN_PATH}")"
	if [ ! -e "${LIBKWIN_DIR}/libkwin.so" ]; then
		echo "[LightlyShaders] Creating compatibility symlink ${LIBKWIN_DIR}/libkwin.so -> libkwin.so.5"
		sudo ln -sf "${LIBKWIN_PATH}" "${LIBKWIN_DIR}/libkwin.so"
	fi
else
	echo "[LightlyShaders] Warning: libkwin.so.5 not found in ldconfig cache."
fi

rm -rf "${BUILD_DIR}"
cmake -S "${WORKTREE_DIR}" -B "${BUILD_DIR}" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
cmake --build "${BUILD_DIR}" -j"$(nproc)"
sudo cmake --install "${BUILD_DIR}"

echo "[LightlyShaders] Qt5 installation finished from ${QT5_TAG}."
