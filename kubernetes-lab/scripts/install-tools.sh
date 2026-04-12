#!/usr/bin/env bash
# install-tools.sh — Install Kubernetes CLI tools for the practice lab
#
# Installs: kubectl, kind, K9s, kubectx+kubens, Stern
#
# Usage:
#   chmod +x scripts/install-tools.sh
#   ./scripts/install-tools.sh
#
# Prerequisites: curl, tar, gzip
# Platform: Linux amd64 (adjust URLs for macOS/ARM if needed)

set -euo pipefail

INSTALL_DIR="${HOME}/.local/bin"
mkdir -p "$INSTALL_DIR"

echo "Install directory: $INSTALL_DIR"
echo "Make sure $INSTALL_DIR is in your PATH."
echo ""

# ---------- kubectl ----------
install_kubectl() {
    if command -v kubectl &>/dev/null; then
        echo "[skip] kubectl already installed: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
        return
    fi
    echo "[install] kubectl..."
    curl -fsSL "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
        -o "$INSTALL_DIR/kubectl"
    chmod +x "$INSTALL_DIR/kubectl"
    echo "[done] kubectl installed"
}

# ---------- kind ----------
install_kind() {
    if command -v kind &>/dev/null; then
        echo "[skip] kind already installed: $(kind version)"
        return
    fi
    echo "[install] kind..."
    local version
    version=$(curl -fsSL https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    curl -fsSL "https://kind.sigs.k8s.io/dl/${version}/kind-linux-amd64" \
        -o "$INSTALL_DIR/kind"
    chmod +x "$INSTALL_DIR/kind"
    echo "[done] kind $version installed"
}

# ---------- K9s ----------
install_k9s() {
    if command -v k9s &>/dev/null; then
        echo "[skip] K9s already installed: $(k9s version --short 2>/dev/null || echo 'installed')"
        return
    fi
    echo "[install] K9s..."
    local version
    version=$(curl -fsSL https://api.github.com/repos/derailed/k9s/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    local tmpdir
    tmpdir=$(mktemp -d)
    curl -fsSL "https://github.com/derailed/k9s/releases/download/${version}/k9s_Linux_amd64.tar.gz" \
        -o "$tmpdir/k9s.tar.gz"
    tar -xzf "$tmpdir/k9s.tar.gz" -C "$tmpdir"
    mv "$tmpdir/k9s" "$INSTALL_DIR/k9s"
    chmod +x "$INSTALL_DIR/k9s"
    rm -rf "$tmpdir"
    echo "[done] K9s $version installed"
}

# ---------- kubectx + kubens ----------
install_kubectx() {
    if command -v kubectx &>/dev/null; then
        echo "[skip] kubectx already installed"
        return
    fi
    echo "[install] kubectx + kubens..."
    local version
    version=$(curl -fsSL https://api.github.com/repos/ahmetb/kubectx/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    local tmpdir
    tmpdir=$(mktemp -d)

    curl -fsSL "https://github.com/ahmetb/kubectx/releases/download/${version}/kubectx_${version}_linux_x86_64.tar.gz" \
        -o "$tmpdir/kubectx.tar.gz"
    tar -xzf "$tmpdir/kubectx.tar.gz" -C "$tmpdir"
    mv "$tmpdir/kubectx" "$INSTALL_DIR/kubectx"

    curl -fsSL "https://github.com/ahmetb/kubectx/releases/download/${version}/kubens_${version}_linux_x86_64.tar.gz" \
        -o "$tmpdir/kubens.tar.gz"
    tar -xzf "$tmpdir/kubens.tar.gz" -C "$tmpdir"
    mv "$tmpdir/kubens" "$INSTALL_DIR/kubens"

    chmod +x "$INSTALL_DIR/kubectx" "$INSTALL_DIR/kubens"
    rm -rf "$tmpdir"
    echo "[done] kubectx + kubens $version installed"
}

# ---------- Stern ----------
install_stern() {
    if command -v stern &>/dev/null; then
        echo "[skip] Stern already installed: $(stern --version 2>/dev/null || echo 'installed')"
        return
    fi
    echo "[install] Stern..."
    local version
    version=$(curl -fsSL https://api.github.com/repos/stern/stern/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    local tmpdir
    tmpdir=$(mktemp -d)
    curl -fsSL "https://github.com/stern/stern/releases/download/${version}/stern_${version#v}_linux_amd64.tar.gz" \
        -o "$tmpdir/stern.tar.gz"
    tar -xzf "$tmpdir/stern.tar.gz" -C "$tmpdir"
    mv "$tmpdir/stern" "$INSTALL_DIR/stern"
    chmod +x "$INSTALL_DIR/stern"
    rm -rf "$tmpdir"
    echo "[done] Stern $version installed"
}

# ---------- Run all ----------
echo "=== Installing Kubernetes CLI tools ==="
echo ""
install_kubectl
install_kind
install_k9s
install_kubectx
install_stern

echo ""
echo "=== Installation complete ==="
echo ""
echo "Verify installations:"
echo "  kubectl version --client"
echo "  kind version"
echo "  k9s version"
echo "  kubectx --help"
echo "  kubens --help"
echo "  stern --version"
echo ""
echo "If commands are not found, add this to your shell profile:"
echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
