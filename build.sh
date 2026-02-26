#!/bin/bash

set -e

LOGFILE="build.log"
exec > >(tee "$LOGFILE") 2>&1

if ! command -v aclocal-1.16 >/dev/null 2>&1 || ! command -v automake-1.16 >/dev/null 2>&1; then
	echo "aclocal-1.16/automake-1.16 (from GNU automake) not found."
	echo "Attempting to install automake via system package manager..."
	if command -v apt-get >/dev/null 2>&1; then
		sudo apt-get update && sudo apt-get install -y automake
	elif command -v dnf >/dev/null 2>&1; then
		sudo dnf install -y automake
	elif command -v pacman >/dev/null 2>&1; then
		sudo pacman -Sy --noconfirm automake
	else
		echo "No supported package manager detected. Please install 'automake' manually and re-run ./build.sh."
		exit 1
	fi

	# After installation, ensure version-suffixed wrappers exist by symlinking
	# automake -> automake-1.16 and aclocal -> aclocal-1.16 in the same directory.
	if command -v automake >/dev/null 2>&1; then
		AUTOMAKE_PATH=$(command -v automake)
		AUTOMAKE_DIR=$(dirname "$AUTOMAKE_PATH")
		if ! command -v automake-1.16 >/dev/null 2>&1; then
			if [ -w "$AUTOMAKE_DIR" ] || sudo -n true 2>/dev/null; then
				echo "Creating symlink $AUTOMAKE_DIR/automake-1.16 -> $AUTOMAKE_PATH (may require sudo)."
				sudo ln -sf "$AUTOMAKE_PATH" "$AUTOMAKE_DIR/automake-1.16"
			else
				echo "Cannot create automake-1.16 symlink automatically; please run:"
				echo "  sudo ln -sf $AUTOMAKE_PATH $AUTOMAKE_DIR/automake-1.16"
				exit 1
			fi
		fi
	fi

	if command -v aclocal >/dev/null 2>&1; then
		ACLOCAL_PATH=$(command -v aclocal)
		ACLOCAL_DIR=$(dirname "$ACLOCAL_PATH")
		if ! command -v aclocal-1.16 >/dev/null 2>&1; then
			if [ -w "$ACLOCAL_DIR" ] || sudo -n true 2>/dev/null; then
				echo "Creating symlink $ACLOCAL_DIR/aclocal-1.16 -> $ACLOCAL_PATH (may require sudo)."
				sudo ln -sf "$ACLOCAL_PATH" "$ACLOCAL_DIR/aclocal-1.16"
			else
				echo "Cannot create aclocal-1.16 symlink automatically; please run:"
				echo "  sudo ln -sf $ACLOCAL_PATH $ACLOCAL_DIR/aclocal-1.16"
				exit 1
			fi
		fi
	else
		echo "aclocal still not available after attempting installation. Please install 'automake' manually."
		exit 1
	fi
fi

cd libusb-1.0.19
./configure --prefix=/usr/local
make
sudo make install
cd ..

cd libusb-compat-0.1.5
./configure --prefix=/usr/local
make
sudo make install
cd ..

cd libhid-0.2.16
./configure --prefix=/usr/local
make
sudo make install
cd ..

cd ultrastikcmd-0.2
./configure --prefix=/usr/local
make
sudo make install
cd ..

sudo ldconfig
