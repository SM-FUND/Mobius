# Mobius

在一台全新的 Ubuntu（x86_64，systemd）上以 root 执行：

```bash
curl -fsSL https://raw.githubusercontent.com/SM-FUND/Mobius/refs/heads/production/install.sh | sudo bash
```

安装完成后访问 `http://<服务器 IP>:8787`。首次打开需要输入安装输出中的初始化码，并绑定 TOTP 验证器（Google Authenticator 等）；之后每次登录输入 6 位动态验证码。

- 丢失验证器：在服务器上执行 `sudo mobius-update reset-auth`，会清除验证器和所有登录会话并打印新的初始化码。
- 控制台使用 HTTP，流量不加密：交易所 API Key 请关闭提现权限，并把 IP 白名单设为本服务器 IP。

- 新版本发布后，控制台右上角会显示“新版本”，点击“立即更新”即可在本机完成升级：运行中的策略先自动停用，新版本启动后自动恢复；新版本启动失败时自动回滚到旧版本和旧数据。
- 数据目录：`/var/lib/mobius/data`；配置：`/etc/mobius/mobius.env`；程序：`/opt/mobius/current`。
- 服务管理：`systemctl status mobius`，日志：`journalctl -u mobius -f`。

本仓库只包含编译后的发行包，由 CI 自动生成，请勿手工提交。
