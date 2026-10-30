#!/usr/bin/env bash
# One-liner to install build dependencies on CachyOS
# Copy-paste this into terminal

echo "=== CachyOS Build Dependency Installer ==="

# Install yay from CachyOS repos (if not already installed)
echo "Step 1: Installing yay (AUR helper)..."
sudo pacman -S --noconfirm yay 2>/dev/null || \
    sudo pacman -S --noconfirm cachyos-aur 2>/dev/null || \
    echo "⚠ If yay not available, install manually: sudo pacman -S cachyos-aur"

# Install base build dependencies
echo ""
echo "Step 2: Installing base build tools..."
sudo pacman -S --noconfirm --needed \
    base-devel \
    git \
    xxd \
    unzip \
    perl \
    make \
    binutils \
    gcc \
    python \
    cmake \
    2>/dev/null

# Install arm-none-eabi-gcc from AUR
echo ""
echo "Step 3: Installing ARM toolchain from AUR..."
yay -S --noconfirm arm-none-eabi-gcc 2>/dev/null || \
    paru -S --noconfirm arm-none-eabi-gcc 2>/dev/null || \
    echo "⚠ If AUR helper failed, install manually:"
    echo "  yay -S arm-none-eabi-gcc"

# Verify installation
echo ""
echo "=== Verification ==="
echo "arm-none-eabi-gcc: $(command -v arm-none-eabi-gcc --version 2>/dev/null | head -1 || echo 'NOT INSTALLED')"
echo "cmake: $(command -v cmake --version 2>/dev/null | head -1 || echo 'NOT INSTALLED')"
echo "git: $(git --version 2>/dev/null | head -1 || echo 'NOT INSTALLED')"

echo ""
echo "Build ready!"