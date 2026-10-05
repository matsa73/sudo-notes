#!/usr/bin/env bash
set -euo pipefail

# Версия по умолчанию v1.3.2, другую можно задать: TAG=v1.3.1 ./v2ray-plugin-setup.sh
TAG="${TAG:-v1.3.2}"

case "$(dpkg --print-architecture)" in
  amd64) ARCH=amd64 ;;
  arm64) ARCH=arm64 ;;
  armhf) ARCH=arm ;;
  i386)  ARCH=386 ;;
  *) echo "Unsupported architecture" >&2; exit 1 ;;
esac

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

curl -fsSL "https://github.com/shadowsocks/v2ray-plugin/releases/download/${TAG}/v2ray-plugin-linux-${ARCH}-${TAG}.tar.gz" \
  | tar -xz -C "$TMP"

BIN=$(find "$TMP" -type f -name 'v2ray-plugin*' | head -n1)
[ -n "$BIN" ] || { echo "Binary not found in archive" >&2; exit 1; }

sha256sum "$BIN"   # запишите хеш, чтобы сверять при обновлениях
sudo install -m 755 "$BIN" /usr/local/bin/v2ray-plugin
v2ray-plugin -version