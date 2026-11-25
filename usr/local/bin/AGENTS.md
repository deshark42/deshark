# 本目录的维护约定

修改仓库中的文件，不要直接修改系统里的副本。

## 部署

首次安装、重建软链，或修改了下表中采用副本安装的文件时，在仓库根目录运行：

```bash
./usr/local/bin/install.sh
```

谁运行脚本，服务就以谁的身份运行：普通用户通过内部 sudo 提权，root 直接执行。它会启用开机自启，但不会启动或重启服务。需要切换或重启服务时，在系统终端执行它打印的命令，不要在 DSH Web 会话中执行。

## 安装方式

| 文件 | 安装方式 |
| --- | --- |
| [dsh-serve](<dsh-serve>)、[dsh-update](<dsh-update>)、[dsh-url](<dsh-url>)、[memo](<memo>) | 系统命令软链到仓库文件，修改后下次执行生效，无需重新部署 |
| [dsh-web@.service](<../../../etc/systemd/system/dsh-web@.service>) | 复制到 /etc/systemd/system |
| [dsh-dev@.service](<../../../etc/systemd/system/dsh-dev@.service>)、[dsh-dev.env.example](<../../../etc/dsh-dev.env.example>) | 只在仓库中留档，`install.sh` 不部署；需要时按下文「dev profile」手动安装 |
| [install.sh](<install.sh>) | 仅在仓库中运行，不安装到系统目录 |
| /etc/dsh-web.env | install.sh 在文件不存在时生成，存放本机 web profile 的 `DSH_ARGS` |
| /etc/dsh-dev.env | 不随 install.sh 生成；手动部署 dev 时按 [dev.env.example](<../../../etc/dsh-dev.env.example>) 创建 |

## 每机配置

unit 的启动参数来自 `/etc/dsh-web.env` 的 `DSH_ARGS`，例如：

```bash
DSH_ARGS=--host 192.0.2.10 --port 3080 --no-open --public-url http://example.com:33080/ --trusted-host example.com:33080
```

不要把它写进仓库，否则多台机器会互相覆盖。改完执行 `systemctl restart dsh-web@$(id -un).service` 生效。

本仓库的 [`etc/dsh-web.env.example`](<../../../etc/dsh-web.env.example>) 是示例值，复制到 `/etc/dsh-web.env` 后按机器修改；`install.sh` 只在文件不存在时生成默认值，不会用它覆盖已有配置。

## dev profile

`dsh-dev@<当前用户名>.service` 与 `dsh-web@` 使用同一个入口脚本，通过 unit 里的 `Environment=DSH_PROFILE=dev` 选择 `$DSH_HOME/profiles/dev`（默认 `127.0.0.1:3081`）。该 profile 用 `dsh --profile dev --from-default-profile web` 创建，是干净的 `@deepseek-ai/dsh-base` + `@deepseek-ai/dsh-web-app` 组合；它与 web profile 共用 `$DSH_HOME` 下的凭据、会话和存储，但插件与 patch 各自独立。

这一套只在仓库里作为版本记录，`install.sh` 不安装、不启用它。需要时在仓库根目录手动部署：

```bash
sudo install -m 644 etc/systemd/system/dsh-dev@.service /etc/systemd/system/
sudo install -m 644 etc/dsh-dev.env.example /etc/dsh-dev.env   # 再按机器改参数
sudo systemctl daemon-reload
sudo systemctl enable --now dsh-dev@$(id -un).service
```

## 远程登录

未登录访问根地址会得到登录页，有两种登录方式：粘贴登录链接，或提交设备配对申请后由已登录浏览器在「设置 → 远程连接」核对显示码批准。登录链接就是 [`dsh-url`](<dsh-url>) 输出的带 `?token=` 地址，与设置页里的登录链接相同，进程重启前可重复使用。

二维码和配对都要求申请方浏览器能访问到公布地址；手机扫码还要求该地址不是回环地址并通过可信 Host 检查，也就是在 `DSH_ARGS` 里配好非回环 `--host`、`--public-url` 和 `--trusted-host`。只监听 127.0.0.1 时设置页只显示登录链接，不显示二维码。

`dsh-update` 更新全局安装的 dsh 并重启服务：普通用户内部调用 sudo，root 直接执行；默认操作 `dsh-web@<当前用户名>.service`，可用 `DSH_SERVICE` 覆盖（例如 `DSH_SERVICE=dsh-dev@$(id -un).service`）。注意它升级的是全局安装，两个 profile 会一起变。加 `-n/--dry-run` 只解析版本并打印计划，不改动服务。

`dsh-url` 从 systemd journal 中读取指定 profile 当前实例启动时输出的、带 `?token=` 的访问 URL：token 每次启动都会重新生成，旧 token 会失效。profile 默认 `web`，也可以传参数选择，例如 `dsh-url dev`；对应 unit 为 `dsh-<profile>@<当前用户名>.service`，要求它处于 active 状态。

## 同步 memo

[memo](<memo>) 保持与上游一致，不单独修改。在仓库根目录同步：

```bash
cp ~/.optmem/memo usr/local/bin/memo
```
