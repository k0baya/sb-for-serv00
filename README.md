## sb-for-Serv00

### 项目特点
* 本项目用于在 [Serv00](https://www.serv00.com/) 部署 Sing-box，采用的方案为 Sing-box + TLS ；

* 无需自备域名，使用 Serv00 自带的域名实现 TLS ；

* 同时支持 Hysteria2 和 Tuic5 、Vless-ws-tls 协议，共 6 种接入方式，并且支持 Warp 出站，可以访问 IPv6 资源；

* 支持 Cloudflare CDN 连入；

* JS 定时保活核心

### TODO

> ~~目前由于 sing-box 的一个 bug，导致设置 Wireguard 出站时会内存错误直接闪退，无法正常使用，故目前本仓库暂不支持 IPv6。待 Sing-box 修复后，再进行更新添加 IPv6 支持。 ~~

### 部署

#### 准备工作

首先你需要至少拥有 1 个托管在 Cloudflare 的域名。

然后参考[群晖套件：Cloudflare Tunnel 内网穿透中文教程 支持DSM6、7](https://imnks.com/5984.html) 的教程，在 Cloudflare 控制面板中创建 1 个 Argo Tunnel，把其中 ey 开头的一串 Token 记录下来备用。

同时你还需要 1 个 Serv00 的账号。

然后是最重要的部分，生成一个 Let's Encrypt 证书：

在 Panel 中点击左侧菜单栏中的 SSL ，然后点击上方菜单栏中的 WWW websites ，点击第一个 IP Address 最右侧的 Manage 按钮，再点击上方菜单栏中的 Add certificate 按钮，Type 选择 Generate Let's Encrypt certificate， Domain任选一个即可，最后点击下方的 Add 按钮进行生成。**请至少保证自己的 Serv00 账号下有一个 Let's Encrypt 的证书，否则无法使用本仓库！**

>友情提示，自己的域名添加 A 类型 DNS 记录指向 Serv00 的服务器后，也可以使用 Serv00 的面板内置的功能添加 Let's Encrypt 的证书，且对本仓库的运行同样有效。同时，**自己的域名不受 Serv00 自带域名申请 SSL 证书时的每周数量限制。**

#### 部署 sb-for-Serv00

SSH 登录 Serv00，输入以下命令：
```shell
devil binexec on && killall -u $(whoami)
```
接着断开 SSH 并重新连接，输入以下命令：
```shell
bash <(curl -Ls https://raw.githubusercontent.com/k0baya/sb-for-serv00/all-in-one/entrypoint.sh)
```
并按照提示输入相关信息。

>**注意**
>
>其中 `ARGO_AUTH`、`ARGO_DOMAIN`、`SERV00PASSWORD` 3 个变量是必须的，其他变量根据需要填写。非必须的变量可以按回车跳过，使用默认值。
>
>`ARGO_AUTH` 为上述的 ey 开头的一串 Token。
>
>`ARGO_DOMAIN` 为 Vless 协议通过 Cloudflare CDN 回源的域名，请使用你域名的子域进行设置，如下图：
>
>![](/pic/argo.png)



#### 启动并获取配置

按照脚本提示进入 `/status` 的网页，并尝试刷新页面，直到进程列表中出现了包含 `sing-box` 以及 `cloudflared` 字样的进程，就代表 Sb-for-Serv00 已经启动成功。此时你就可以通过访问 `/list` 路径查看到 Sb-for-Serv00 所提供的配置链接了。
![](/pic/process.png)

### 自动启动

Sb-for-Serv00 可以通过访问网页对项目进行唤醒，如果你需要保活，可以使用以下公共服务对网页进行监控：

1 [cron-job.org](https://console.cron-job.org)

2 [UptimeRobot](https://uptimerobot.com/) 

同时，你也可以选择自建 [Uptime-Kuma](https://github.com/louislam/uptime-kuma) 等服务进行监控。

>建议监控 `/info` 路径，因为该路径无需身份验证。
>
>不要监控根路径，因为根路径为静态页面，只是该项目的伪装，无法起到保活效果。

### 常见问题
1. 已知部分 Server （目前已知 s7 和 s8）已经使用 hosts 屏蔽了 Cloudflared 客户端的下载地址，可以通过手动上传二进制文件的方法解决，具体参照：[#19](https://github.com/k0baya/X-for-serv00/issues/19#issuecomment-2266315320)
2. 已知部分客户端（如 V2rayNG）可能出现导入配置识别不正确的情况，如 vless 协议 `ws path` 应为 `/serv00-vl` ，如果客户端识别不完整，通过手动补全即可正常使用。