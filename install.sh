#!/usr/bin/env bash
# Mobius 一键安装：
#   curl -fsSL https://raw.githubusercontent.com/SM-FUND/Mobius/refs/heads/production/install.sh | sudo bash
# 下载最新编译版本并校验 SHA-256，随后交给发行包内的 mobius-update 完成安装。
# 重复执行会把程序重装为最新版本，保留 /var/lib/mobius 中的数据与 /etc/mobius 中的配置。
set -euo pipefail

MANIFEST_URL=${MOBIUS_RELEASE_MANIFEST_URL:-https://raw.githubusercontent.com/SM-FUND/Mobius/production/latest.json}

fail() { echo "[mobius] $*" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] || fail "请使用 root 运行：curl ... | sudo bash"
case "$(uname -m)" in x86_64 | amd64) ;; *) fail "仅支持 x86_64 架构，当前为 $(uname -m)" ;; esac
command -v systemctl >/dev/null && [ -d /run/systemd/system ] || fail "需要 systemd"
# 发行版只在 Ubuntu 22.04/24.04 上验证；其他系统继续安装但不保证可用。
. /etc/os-release 2>/dev/null || true
[ "${ID:-}" = "ubuntu" ] || echo "[mobius] 警告：Mobius 只支持 Ubuntu 22.04/24.04，当前系统为 ${PRETTY_NAME:-未知}，继续安装但不保证可用。" >&2
for tool in curl tar sha256sum flock; do
  command -v "$tool" >/dev/null && continue
  command -v apt-get >/dev/null || fail "缺少 $tool，请先安装"
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
[ -n "$version" ] && [ -n "$url" ] && [ -n "$sha256" ] || fail "发行清单无效：$MANIFEST_URL"

echo "[mobius] 下载 Mobius $version ..."
curl -fSL --retry 3 -o "$tmp/release.tar.gz" "$url"
echo "$sha256  $tmp/release.tar.gz" | sha256sum -c --quiet - || fail "发行包校验失败"
mkdir "$tmp/pkg"
tar -xzf "$tmp/release.tar.gz" -C "$tmp/pkg" ./bin/mobius-update
MOBIUS_RELEASE_MANIFEST_URL=$MANIFEST_URL bash "$tmp/pkg/bin/mobius-update" install "$tmp/release.tar.gz"

ip=$(curl -fsS --max-time 5 https://api.ipify.org 2>/dev/null || hostname -I | awk '{print $1}')
cat <<MSG

[mobius] 安装完成：http://$ip:8787
[mobius] 首次打开时输入上面的初始化码并绑定 TOTP 验证器（Google Authenticator 等），之后每次登录都需要动态验证码。
[mobius] 丢失验证器：sudo mobius-update reset-auth（清除验证器并生成新的初始化码）。
[mobius] 控制台通过 HTTP 访问，流量未加密：交易所 API Key 务必关闭提现权限，并把 IP 白名单设为本机 $ip。
[mobius] 服务管理：sudo systemctl status mobius ｜ 日志：sudo journalctl -u mobius -f
[mobius] 云服务器还需在安全组 / 防火墙放行 TCP 8787（ufw：sudo ufw allow 8787/tcp）。
[mobius] 之后的版本更新在控制台右上角一键完成，无需再次执行本脚本。
MSG
