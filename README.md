## sb-for-Serv00

### 项目特点
* 本项目用于在 [Serv00](https://www.serv00.com/) 部署 Sing-box，采用的方案为 Sing-box + TLS ；

* 无需自备域名，使用 Serv00 自带的域名实现 TLS ；

* 同时支持 Hysteria2、Tuic5 和 Naïve 三协议；

* JS 定时保活核心

### TODO

> 目前由于 sing-box 的一个 bug，导致设置 Wireguard 出站时会内存错误直接闪退，无法正常使用，故目前本仓库暂不支持 IPv6。待 Sing-box 修复后，再进行更新添加 IPv6 支持。 

### 部署
#### 准备工作

首先你需要至少拥有 1 个托管在 Cloudflare 的域名。

然后参考[群晖套件：Cloudflare Tunnel 内网穿透中文教程 支持DSM6、7](https://imnks.com/5984.html) 的教程，在 Cloudflare 控制面板中创建 1 个 Argo Tunnel，把其中 ey 开头的一串 Token 记录下来备用。

同时你还需要 1 个 Serv00 的账号。

>如果你之前放行过端口，请确保你的端口不是 TCP 类型，如果放行过 TCP 端口，请将其删除。

#### 部署 sb-for-Serv00

SSH 登录 Serv00，输入以下命令以激活运行许可：
```shell
devil binexec on
```
接着断开 SSH 并重新连接，输入以下命令：
```shell
bash <(curl -Ls https://raw.githubusercontent.com/k0baya/sb-for-serv00/main/install.sh)
```
并按照提示输入相关信息。

#### 启动并获取配置

按照脚本提示进入 `/status` 的网页，并尝试刷新页面，直到进程列表中出现了包含 `sing-box` 字样的进程，就代表 Sb-for-Serv00 已经启动成功。此时你就可以通过访问 `/list` 路径查看到 Sb-for-Serv00 所提供的配置链接了。

### 自动启动

此次版本更新之后，Sb-for-Serv00 已经可以摆脱 Serv00 的 Crontab 启动，你可以通过访问网页对项目进行唤醒，如果你需要保活，可以使用以下公共服务对网页进行监控：

1 [cron-job.org](https://console.cron-job.org)

2 [UptimeRobot](https://uptimerobot.com/) 

同时，你也可以选择自建 [Uptime-Kuma](https://github.com/louislam/uptime-kuma) 等服务进行监控。

>建议监控 `/info` 路径，因为该路径无需身份验证。
>
>不要监控根路径，因为根路径为静态页面，只是该项目的伪装，无法起到保活效果。

### 常见问题
1. 为什么连不上？

如果 `/status` 页面中 `sing-box` 进程正常运行，那么说明本项目运行正常，连接不上与 GFW 有关，已知 UDP 协议的连接经常会受到 GFW 的干扰。

2. 为什么放行端口失败？

如果脚本自动放行端口失败，请手动去面板中添加三个类型为 UDP 的端口，再重新执行安装脚本。

补充中...