# Mobius 跨交易所套利引擎

[![Release](https://img.shields.io/github/v/release/SM-FUND/Mobius?label=release&color=1f6feb)](https://github.com/SM-FUND/Mobius/releases/latest)
[![Platform](https://img.shields.io/badge/platform-Linux%20x86__64-orange)](#运行环境)
[![Install](https://img.shields.io/badge/install-一行命令-2ea44f)](#一键安装)

Mobius 用来监控多个交易所之间同一币种的价差，在满足策略与风控条件时同时下两条腿，并在控制台里管理策略、仓位、成交和收益。

本仓库只发布编译好的 Linux x86_64 程序，不包含源码、用户配置、数据库或任何交易凭据。程序安装在你自己的服务器上，API Key 只保存在你的服务器。

---

## 使用前须知

本工具涉及数字资产交易。出现价差不代表一定能获利，实际结果会受到以下因素影响：

- 交易手续费、资金费率和其他平台费用
- 网络延迟、行情变化和订单簿深度
- 滑点、部分成交、两条腿成交不同步
- 交易所 API、WebSocket 异常或规则变化
- 保证金、仓位、强平与账户权限风险
- 你所在国家或地区的法律、监管和平台访问限制

请先用小额资金测试，确认账户、方向、数量和风控参数都正确后再加大规模。本工具不构成投资建议，不承诺收益，交易、账户和资金风险由使用者自行承担。

---

## 支持的交易所与策略

| 交易所 | 现货 | 合约 |
|---|:-:|:-:|
| Binance | ✓ | ✓ |
| OKX | ✓ | ✓ |
| Bybit | ✓ | ✓ |
| Bitget | ✓ | ✓ |
| Gate | ✓ | ✓ |
| Hyperliquid | ✓ | ✓ |
| Aster | ✓ | ✓ |
| Kraken | ✓ | ✓ |

- **价差策略**：现货/合约任意组合的两腿价差开平仓，支持仓位阶梯。
- **期汇比值策略（FR / SR）**：按两腿价格比值开平仓。
- **风控**：最大仓位、止损、风险强减、一键清仓；两腿未确认的订单会按原订单身份查询确认，不会重复下单。

具体可用的产品以控制台里“添加价差”时能搜索到的为准。

---

## 运行环境

| 项目 | 要求 |
|---|---|
| 操作系统 | Ubuntu 22.04 / 24.04（只支持 Ubuntu） |
| 架构 | x86_64 |
| CPU / 内存 | 2 核 / 2 GB 即可 |
| 磁盘 | 20 GB 及以上 |
| 网络 | 稳定、低延迟，能访问各交易所 API；推荐日本、新加坡等离交易所近的地区 |
| 端口 | 控制台使用 TCP 8787 |

检查服务器架构：

```bash
uname -m
```

输出应为 `x86_64`。如果是 `aarch64` 或 `arm64`，当前版本不能运行。

---

## 一键安装

在一台全新的 Ubuntu 服务器上执行：

```bash
curl -fsSL https://raw.githubusercontent.com/SM-FUND/Mobius/refs/heads/production/install.sh | sudo bash
```

安装脚本会：

1. 下载最新版本的发行包，并校验 SHA-256，校验失败立即退出；
2. 创建系统用户 `mobius`，把程序安装为开机自启的 systemd 服务；
3. 启动服务并打印控制台地址和**初始化码**。

安装成功时，最后会看到类似输出：

```text
[mobius] Mobius 0.3.0+62 installed.
[mobius] Console:    http://203.0.113.10:8787
[mobius] Setup code: ABCD-EFGH-IJKL-MNOP
```

**请保存好初始化码，不要截图外传**：在绑定验证器之前，拿到“IP + 初始化码”的人就能接管控制台。

> 安装和运维命令的终端输出都是英文：AWS Lightsail 等云厂商的网页终端往往缺少中文字体，中文会显示成方框。控制台界面仍是中文。

### 放行 8787 端口

云服务器通常还有一层安全组或防火墙，需要放行 TCP 8787，否则浏览器打不开控制台：

- 在云厂商控制台的“安全组 / 防火墙”里添加入站规则：TCP 8787，来源尽量只填你自己的 IP。
- 如果服务器启用了 ufw：

```bash
sudo ufw allow 8787/tcp
```

---

## 首次登录

1. 浏览器打开 `http://<服务器 IP>:8787`。
2. 输入安装输出中的初始化码。
3. 用 Google Authenticator、Microsoft Authenticator、1Password 等验证器 App 扫描页面上的二维码。
4. 输入验证器显示的 6 位动态验证码，完成绑定并进入控制台。

绑定后初始化码立即作废，以后每次登录只需要输入 6 位动态验证码。登录会话有效期为 12 小时。

---

## 配置交易所 API Key

在控制台“设置 → 交易所”中添加账户。创建 API Key 时请务必：

- **只开启交易和读取权限，关闭提现权限**；
- **把 IP 白名单设为这台服务器的公网 IP**；
- 每个交易所单独创建一个仅供 Mobius 使用的 Key，不要和其他程序共用。

API Key 保存后会在服务器上加密存储，控制台不会再显示明文。

---

## 安全说明

- 控制台必须先绑定 TOTP 验证器才能使用，没有初始化码的人无法抢先接管。
- 连续输错初始化码或验证码会被锁定：同一 IP 输错 5 次锁定 1 分钟，之后每次翻倍，最长 1 小时。
- 同一个 6 位验证码只能使用一次，不能被截获后重放。
- **控制台使用 HTTP 访问，流量不加密。** 会话和在页面上填写的 API Key 都会以明文经过网络。因此上面“关闭提现权限 + IP 白名单”是必须做的，安全组的 8787 来源也建议只放行你自己的 IP。需要加密时，可以自行在前面加一层带证书的反向代理。

---

## 在线更新

新版本发布后，控制台右上角会出现“新版本 vX.X.X.X”按钮。点击“立即更新”后：

1. 运行中的策略会先自动停用；
2. 服务器下载新版本并校验，备份数据后切换版本，服务重启约 1 分钟；
3. 新版本启动后，之前停用的策略自动恢复为原来的状态；
4. 新版本启动失败时，自动回滚到旧版本和更新前的数据。

更新完成后页面会自动刷新。不需要重新执行安装命令。

所有版本和更新说明见 [Releases](https://github.com/SM-FUND/Mobius/releases)。

---

## 常用命令

```bash
# 查看服务状态
sudo systemctl status mobius

# 实时查看日志
sudo journalctl -u mobius -f

# 查看最近 100 行日志
sudo journalctl -u mobius -n 100 --no-pager

# 重启服务
sudo systemctl restart mobius

# 查看在线更新的日志
sudo journalctl -u mobius-update -n 50 --no-pager

# 丢失验证器：清除验证器和所有登录会话，并打印新的初始化码
sudo mobius-update reset-auth

# 重新安装最新版本（保留数据和配置）
curl -fsSL https://raw.githubusercontent.com/SM-FUND/Mobius/refs/heads/production/install.sh | sudo bash
```

---

## 文件位置

| 路径 | 内容 |
|---|---|
| `/opt/mobius/current` | 当前运行的程序（指向 `/opt/mobius/releases/<版本>`） |
| `/var/lib/mobius/data` | 账户、账本、行情历史等数据（含加密的 API Key） |
| `/var/lib/mobius/backups` | 最近一次在线更新前的数据备份 |
| `/etc/mobius/mobius.env` | 服务配置 |

备份时请备份整个 `/var/lib/mobius/data`，并加密保存在其他地方。

---

## 常见问题

**浏览器打不开控制台**

先确认服务在运行：`sudo systemctl status mobius`。如果服务正常，通常是云厂商安全组或 ufw 没有放行 TCP 8787。

**找不到初始化码**

执行 `sudo mobius-update reset-auth`，会生成并打印新的初始化码。注意这会清除已绑定的验证器和所有登录会话。

**提示“验证失败次数过多”**

输错次数过多后被暂时锁定，等待提示的时间后再试，最长 1 小时。重启服务（`sudo systemctl restart mobius`）也会清除锁定。

**更新失败**

控制台会显示失败原因，程序会自动回滚到旧版本，策略会恢复。查看原因：`sudo journalctl -u mobius-update -n 50 --no-pager`。

**卸载**

```bash
sudo systemctl disable --now mobius mobius-update.path
sudo rm -f /etc/systemd/system/mobius.service /etc/systemd/system/mobius-update.path /etc/systemd/system/mobius-update.service /usr/local/sbin/mobius-update
sudo systemctl daemon-reload
sudo rm -rf /opt/mobius
```

上面的命令会保留数据和配置。确认不再需要后，再执行 `sudo rm -rf /var/lib/mobius /etc/mobius` 删除全部数据（包括 API Key），并执行 `sudo userdel mobius` 删除系统用户。

---

本仓库内容由发布流程自动生成，请勿直接提交修改。
