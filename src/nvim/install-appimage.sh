# Detect architecture
# https://learn.microsoft.com/en-us/windows/msix/package/device-architecture
arch=$(arch | sed s/aarch64/arm64/ | sed s/x86_64/x86_64/)
if [ "$arch" != "x86_64" ] && [ "$arch" != "aarch64" ]; then
  echo -e "${RED}ERROR: Unsupported architecture '$arch'. Only x86_64 and aarch64 (ARM64) are supported."
  exit 1
fi

# Install
echo -e "Installing neovim via appimage: https://neovim.io/doc/install/#appimage-universal-linux-package"
curl -LO "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${arch}.appimage"
chmod u+x nvim-linux-${arch}.appimage
mkdir -p /opt/nvim
mv nvim-linux-x86_64.appimage /opt/nvim/nvim
# add to path: /opt/nvim/
