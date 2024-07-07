## sb-for-Serv00

### 项目特点
* 本项目用于在 [Serv00](https://www.serv00.com/) 部署 Sing-box，采用的方案为 Sing-box + TLS ；

* 无需自备域名，使用 Serv00 自带的域名实现 TLS ；

* 同时支持 Hysteria2 和 Tuic5 双协议；

* JS 定时保活核心

### TODO

> 目前由于 sing-box 的一个 bug，导致设置 Wireguard 出站时会内存错误直接闪退，无法正常使用，故目前本仓库暂不支持 IPv6。待 Sing-box 修复后，再进行更新添加 IPv6 支持。 

### 部署

#### 准备工作

首先在 Panel 中放行两个类型为 UDP 端口，并在 Additional services 选项卡中找到 Run your own applications 项目，将其设置为 Enabled 。

然后是最重要的部分，生成一个 Let's Encrypted 证书：

在 Panel 中点击左侧菜单栏中的 SSL ，然后点击上方菜单栏中的 WWW websites ，点击第一个 IP Address 最右侧的 Manage 按钮，再点击上方菜单栏中的 Add certificate 按钮，Type 选择 Generate Let's Encrypted certificate， Domain任选一个即可，最后点击下方的 Add 按钮进行生成。请至少保证自己的 Serv00 账号下有一个 Let's Encrypted 的证书。

接着进入 File manager，在用户目录下新建一个名为`sing-box`的文件夹用于部署 sb-for-Serv00，并将本仓库的文件都上传到此文件夹内。

右键点击 `start.sh` 文件，选择 View/Edit > Source Editor ，进行编辑，在 1 - 7 行修改环境变量：
|变量名|是否必须|默认值|备注|
|-|-|-|-|
|HY2PORT|是||Hysteria2 协议监听端口|
|TUIC5PORT|是||Tuic5 协议监听端口|
|SERV00PASSWORD|是||你的 Serv00 账号的密码，用于获取 SSL 证书|
|UUID|否|de04add9-5c68-8bab-950c-08cd5320df18||

#### 启动并获取配置

SSH 登录 Serv00 ，进入 `start.sh` 所在的路径，直接执行即可启动。

```
chmod +x start.sh && bash start.sh
```
等待程序完成启动，会在 Terminal 中直接打印出 Hysteria2 和 Tuic5 的配置链接。

### 自动启动

听说 Serv00 的主机会不定时重启，所以需要添加自启任务。

在 Panel 中找到 Cron jobs 选项卡，使用 Add cron job 功能添加任务，Specify time 选择 After reboot，即为重启后运行。Form type 选择 Advanced，Command 写 `start.sh` 文件的绝对路径，比如：

```
/home/username/sing-box/start.sh >/dev/null 2>&1
```
> 务必按照你的实际路径进行填写。
