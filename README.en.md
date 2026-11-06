# Mobius Cross-Exchange Arbitrage Engine

[简体中文](README.md) | **English** | [日本語](README.ja.md) | [한국어](README.ko.md)

[![Release](https://img.shields.io/github/v/release/SM-FUND/Mobius?label=release&color=1f6feb)](https://github.com/SM-FUND/Mobius/releases/latest)
[![Platform](https://img.shields.io/badge/platform-Linux%20x86__64-orange)](#requirements)
[![Install](https://img.shields.io/badge/install-one--line-2ea44f)](#one-line-install)

Mobius monitors the spread of the same coin across multiple exchanges, places both legs at once when your strategy and risk conditions are met, and lets you manage strategies, positions, fills and profit from a web console.

This repository only publishes the compiled Linux x86_64 program. It contains no source code, user configuration, database or trading credentials. The program runs on your own server, and your API keys are stored only on that server.

---

## Before you start

This tool trades digital assets. A spread does not guarantee a profit; actual results depend on:

- Trading fees, funding rates and other platform fees
- Network latency, market moves and order book depth
- Slippage, partial fills, and the two legs filling out of sync
- Exchange API or WebSocket failures and rule changes
- Margin, position, liquidation and account permission risks
- The laws, regulations and platform access restrictions of your country or region

Start with a small amount. Increase size only after you have confirmed that accounts, directions, quantities and risk parameters are correct. This tool is not investment advice and does not promise any return. You bear all trading, account and funds risk.

---

## Supported exchanges and strategies

| Exchange | Spot | Futures |
|---|:-:|:-:|
| Binance | ✓ | ✓ |
| OKX | ✓ | ✓ |
| Bybit | ✓ | ✓ |
| Bitget | ✓ | ✓ |
| Gate | ✓ | ✓ |
| Hyperliquid | ✓ | ✓ |
| Aster | ✓ | ✓ |
| Kraken | ✓ | ✓ |

- **Spread strategy**: open and close two-leg spreads on any spot/futures combination, with position ladders.
- **Futures ratio strategies (FR / SR)**: open and close by the price ratio of the two legs.
- **Risk controls**: maximum position, stop loss, forced risk reduction and one-click close-all. Unconfirmed orders on either leg are confirmed by querying the original order, never by placing a duplicate.

The products actually available are those you can find when searching in **Add spread** in the console.

---

## Requirements

| Item | Requirement |
|---|---|
| Operating system | Ubuntu 22.04 / 24.04 (Ubuntu only) |
| Architecture | x86_64 |
| CPU / memory | 2 cores / 2 GB is enough |
| Disk | 20 GB or more |
| Network | Stable, low latency, able to reach the exchange APIs; regions close to the exchanges such as Japan or Singapore are recommended |
| Port | The console uses TCP 8787 |

Check the server architecture:

```bash
uname -m
```

The output should be `x86_64`. If it is `aarch64` or `arm64`, the current version cannot run.

---

## One-line install

On a fresh Ubuntu server, run:

```bash
curl -fsSL https://raw.githubusercontent.com/SM-FUND/Mobius/refs/heads/production/install.sh | sudo bash
```

The installer will:

1. Download the latest release and verify its SHA-256, exiting immediately if verification fails;
2. Create the system user `mobius` and install the program as a systemd service that starts on boot;
3. Start the service and print the console address and a **setup code**.

A successful install ends with output like:

```text
[mobius] Mobius 0.3.0+62 installed.
[mobius] Console:    http://203.0.113.10:8787
[mobius] Setup code: ABCD-EFGH
```

**Keep the setup code private and do not share screenshots of it**: until an authenticator is bound, anyone with the "IP + setup code" can take over the console.

> Terminal output of the install and maintenance commands is in English, because web terminals from cloud providers such as AWS Lightsail often lack CJK fonts. The console interface can be switched between Chinese and English in Settings.

### Open port 8787

Cloud servers usually have a security group or firewall in front of them. Allow TCP 8787, or the browser cannot reach the console:

- In your cloud provider's "security group / firewall", add an inbound rule for TCP 8787, with the source limited to your own IP where possible.
- If ufw is enabled on the server:

```bash
sudo ufw allow 8787/tcp
```

---

## First login

1. Open `http://<server IP>:8787` in a browser.
2. Enter the setup code from the install output.
3. Scan the QR code on the page with an authenticator app such as Google Authenticator, Microsoft Authenticator or 1Password.
4. Enter the 6-digit code shown in the app to finish binding and enter the console.

The setup code becomes invalid as soon as binding completes. From then on, log in with just the 6-digit code. A login session lasts 12 hours.

---

## Configure exchange API keys

Add accounts in the console under **Settings → Exchange**. When creating an API key, make sure to:

- **Enable only trading and read permissions, and disable withdrawals**;
- **Set the IP allowlist to this server's public IP**;
- Create a dedicated key for Mobius on each exchange; do not share it with other programs.

Once saved, API keys are stored encrypted on the server and the console never shows them in plain text again.

---

## Security notes

- The console cannot be used until a TOTP authenticator is bound, so nobody without the setup code can take it over first.
- Repeated wrong setup codes or 6-digit codes trigger a lockout: 5 failures from the same IP lock it for 1 minute, doubling each time, up to 1 hour.
- Each 6-digit code can be used only once and cannot be replayed if intercepted.
- **The console is served over HTTP and traffic is not encrypted.** Sessions and any API keys entered on the page cross the network in plain text. That is why "disable withdrawals + IP allowlist" above is mandatory, and the security group should allow port 8787 only from your own IP. If you need encryption, put a reverse proxy with a certificate in front.

---

## Online updates

When a new version is released, a new-version button (`新版本 vX.X.X.X`) appears at the top right of the console. After you click Update now:

1. Running strategies are disabled automatically first;
2. The server downloads and verifies the new version, backs up data and switches versions; the service restarts in about 1 minute;
3. Once the new version is up, the strategies that were disabled are restored to their previous state;
4. If the new version fails to start, it rolls back to the old version and the pre-update data automatically.

The page refreshes by itself when the update finishes. There is no need to rerun the install command.

All versions and release notes are on [Releases](https://github.com/SM-FUND/Mobius/releases).

---

## Common commands

```bash
# Service status
sudo systemctl status mobius

# Follow the logs
sudo journalctl -u mobius -f

# Last 100 log lines
sudo journalctl -u mobius -n 100 --no-pager

# Restart the service
sudo systemctl restart mobius

# Online update logs
sudo journalctl -u mobius-update -n 50 --no-pager

# Lost authenticator: clear the authenticator and all login sessions, and print a new setup code
sudo mobius-update reset-auth

# Reinstall the latest version (keeps data and configuration)
curl -fsSL https://raw.githubusercontent.com/SM-FUND/Mobius/refs/heads/production/install.sh | sudo bash
```

---

## File locations

| Path | Contents |
|---|---|
| `/opt/mobius/current` | The running program (points to `/opt/mobius/releases/<version>`) |
| `/var/lib/mobius/data` | Accounts, ledger, market history and other data (including encrypted API keys) |
| `/var/lib/mobius/backups` | Data backup taken before the most recent online update |
| `/etc/mobius/mobius.env` | Service configuration |

To back up, copy the whole `/var/lib/mobius/data` directory and keep it encrypted somewhere else.

---

## FAQ

**The browser cannot open the console**

First check that the service is running: `sudo systemctl status mobius`. If it is, the cloud security group or ufw usually has not allowed TCP 8787.

**I can't find the setup code**

Run `sudo mobius-update reset-auth` to generate and print a new setup code. Note that this clears the bound authenticator and all login sessions.

**The page says “验证失败次数过多” (too many failed attempts)**

You are temporarily locked out after too many wrong entries. Wait for the time shown and try again (at most 1 hour). Restarting the service (`sudo systemctl restart mobius`) also clears the lockout.

**The update failed**

The console shows the reason, the program rolls back to the old version automatically, and strategies are restored. To see why: `sudo journalctl -u mobius-update -n 50 --no-pager`.

**Uninstall**

```bash
sudo systemctl disable --now mobius mobius-update.path
sudo rm -f /etc/systemd/system/mobius.service /etc/systemd/system/mobius-update.path /etc/systemd/system/mobius-update.service /usr/local/sbin/mobius-update
sudo systemctl daemon-reload
sudo rm -rf /opt/mobius
```

The commands above keep data and configuration. Once you are sure you no longer need them, run `sudo rm -rf /var/lib/mobius /etc/mobius` to delete all data (including API keys), and `sudo userdel mobius` to remove the system user.

---

This repository is generated by the release pipeline. Please do not commit changes directly.
