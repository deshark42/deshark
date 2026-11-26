#!/usr/bin/env bash
# 把仓库里的脚本和 systemd unit 部署到系统。
# 谁运行本脚本，服务就以谁的身份运行；非 root 用户通过 sudo 完成需要权限的步骤。

set -euo pipefail

repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)
user=$(id -un)
unit="dsh-web@${user}.service"
env_file=/etc/dsh-web.env

die() { echo "错误：$*" >&2; exit 1; }

# root 运行时无需 sudo；其他用户要求能用 sudo。
if [[ $EUID -eq 0 ]]; then
  SUDO=()
else
  command -v sudo >/dev/null 2>&1 || die "缺少 sudo"
  SUDO=(sudo)
fi

# 仓库文件缺失时尽早失败，避免留下指向不存在文件的软链
for f in dsh-serve dsh-update dsh-url; do
  [[ -f "$repo/usr/local/bin/$f" ]] || die "缺少仓库文件：$repo/usr/local/bin/$f"
done

# 普通用户运行的脚本用软链，改仓库即生效
for f in dsh-serve dsh-update dsh-url; do
  "${SUDO[@]}" ln -sfn "$repo/usr/local/bin/$f" "/usr/local/bin/$f"
done

# 覆盖前先校验 unit，避免把语法错误或错误路径装进 /etc
unit_src="$repo/etc/systemd/system/dsh-web@.service"
[[ -f "$unit_src" ]] || die "缺少仓库 unit：$unit_src"
if command -v systemd-analyze >/dev/null 2>&1; then
  systemd-analyze verify "$unit_src" || die "systemd-analyze verify 未通过：$unit_src"
fi
# 模板 unit 的实例名是用户名，User= 取自实例名
"${SUDO[@]}" install -m 644 "$unit_src" /etc/systemd/system/dsh-web@.service

# 监听地址和对外 URL 因机器而异，不要写进仓库：首次部署时生成默认值
if [[ ! -e "$env_file" ]]; then
  printf 'DSH_ARGS=--host 127.0.0.1 --port 3080\n' \
    | "${SUDO[@]}" tee "$env_file" >/dev/null
fi

"${SUDO[@]}" systemctl daemon-reload
"${SUDO[@]}" systemctl enable "$unit" >/dev/null

prefix=${SUDO[*]:+${SUDO[*]} }
echo "已部署 $unit（来自 $repo），未启动或重启服务。"
echo "请在系统终端执行（会中断当前 Web 会话）："
echo "  ${prefix}systemctl restart $unit"
