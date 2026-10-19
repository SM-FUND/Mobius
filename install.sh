#!/usr/bin/env bash
# Mobius 一键安装：
#   curl -fsSL https://raw.githubusercontent.com/SM-FUND/Mobius/refs/heads/production/install.sh | sudo bash
# 下载最新编译版本并校验 SHA-256，随后交给发行包内的 mobius-update 完成安装。
# 重复执行会把程序重装为最新版本，保留 /var/lib/mobius 中的数据与 /etc/mobius 中的配置。
# 终端输出只用英文：云厂商网页终端（如 Lightsail）常缺中文字体，中文会显示成方框。
set -euo pipefail

MANIFEST_URL=${MOBIUS_RELEASE_MANIFEST_URL:-https://raw.githubusercontent.com/SM-FUND/Mobius/production/latest.json}
SETUP_CODE_FILE=/var/lib/mobius/data/control/setup-code.txt

say() { echo "[mobius] $*"; }
fail() { echo "[mobius] ERROR: $*" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] || fail "run as root: curl -fsSL <install.sh url> | sudo bash"
case "$(uname -m)" in x86_64 | amd64) ;; *) fail "only x86_64 is supported (this machine: $(uname -m))" ;; esac
command -v systemctl >/dev/null && [ -d /run/systemd/system ] || fail "systemd is required"
# 发行版只在 Ubuntu 22.04/24.04 上验证；其他系统继续安装但不保证可用。
. /etc/os-release 2>/dev/null || true
[ "${ID:-}" = "ubuntu" ] || say "WARNING: only Ubuntu 22.04/24.04 is supported (this system: ${PRETTY_NAME:-unknown}); continuing anyway." >&2
for tool in curl tar sha256sum flock; do
  command -v "$tool" >/dev/null && continue
  command -v apt-get >/dev/null || fail "missing $tool, please install it first"
  apt-get update -qq && apt-get install -y -qq curl ca-certificates tar coreutils util-linux >/dev/null
  break
done

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
manifest=$(curl -fsSL --retry 3 -H 'Cache-Control: no-cache' "$MANIFEST_URL?t=$(date +%s)")
field() { echo "$manifest" | sed -n "s/^[[:space:]]*\"$1\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" | head -n1; }
version=$(field version)
url=$(field url)
sha256=$(field sha256)
[ -n "$version" ] && [ -n "$url" ] && [ -n "$sha256" ] || fail "invalid release manifest: $MANIFEST_URL"

say "Downloading Mobius $version ..."
curl -fsSL --retry 3 -o "$tmp/release.tar.gz" "$url"
echo "$sha256  $tmp/release.tar.gz" | sha256sum -c --quiet - || fail "checksum mismatch, aborting"
say "Checksum OK. Installing ..."
mkdir "$tmp/pkg"
tar -xzf "$tmp/release.tar.gz" -C "$tmp/pkg" ./bin/mobius-update
MOBIUS_RELEASE_MANIFEST_URL=$MANIFEST_URL bash "$tmp/pkg/bin/mobius-update" install "$tmp/release.tar.gz"

ip=$(curl -fsS --max-time 5 https://api.ipify.org 2>/dev/null || hostname -I | awk '{print $1}')
echo
say "Mobius $version installed."
say "Console:    http://$ip:8787"
if [ -s "$SETUP_CODE_FILE" ]; then
  code=$(cat "$SETUP_CODE_FILE")
  say "Setup code: $(echo "$code" | sed 's/.\{4\}/&-/g; s/-$//')"
  say "On first visit enter the setup code, then scan the QR code with an authenticator app"
  say "(Google Authenticator, 1Password, ...). The setup code is invalid once bound. Keep it private."
else
  say "Authenticator already bound: log in with the 6-digit code from your authenticator app."
fi
cat <<MSG

[mobius] Open TCP 8787 in your cloud security group / firewall (ufw: sudo ufw allow 8787/tcp).
[mobius] The console uses plain HTTP: for every exchange API key, DISABLE withdrawals and
[mobius] whitelist only this server's IP ($ip).
[mobius] Lost your authenticator:  sudo mobius-update reset-auth
[mobius] Service status:           sudo systemctl status mobius
[mobius] Live logs:                sudo journalctl -u mobius -f
[mobius] Future updates: use the update button at the top right of the console. No need to rerun this script.
MSG
