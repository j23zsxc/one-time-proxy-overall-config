#!/bin/zsh

# 颜色定义
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_CYAN='\033[0;36m'
COLOR_BOLD='\033[1m'
COLOR_RESET='\033[0m'

# 定义一个取消代理的函数
# 这个函数也会被导出, 所以你可以在任何时候在终端里运行 `unset_proxy` 来清除代理
unset_proxy() {
    unset http_proxy
    unset HTTP_PROXY
    unset https_proxy
    unset HTTPS_PROXY
    unset all_proxy
    unset ALL_PROXY
    unset no_proxy
    unset NO_PROXY
    echo -e "${COLOR_GREEN}已清除所有代理设置${COLOR_RESET}"
}

# 将取消代理的函数导出到当前shell环境
export -f unset_proxy

# 先清除任何可能存在的旧代理设置
unset_proxy

# 显示选项菜单
echo -e "${COLOR_CYAN}请选择您想配置的Proxy (仅限当前Terminal):${COLOR_RESET}"
echo -e "${COLOR_BOLD}1. NaiveProxy  ${COLOR_RESET}(Socks5: 127.0.0.1:1080)"
echo -e "${COLOR_BOLD}2. Juicity     ${COLOR_RESET}(HTTPS/Socks5: 127.0.0.1:4080)"
echo -e "${COLOR_BOLD}3. Hysteria1   ${COLOR_RESET}(HTTPS: 127.0.0.1:3081)"
echo -e "${COLOR_BOLD}4. Hysteria2   ${COLOR_RESET}(Socks5: 127.0.0.1:2080)"
echo -e "${COLOR_BOLD}5. v2rayN      ${COLOR_RESET}(HTTP/HTTPS: 127.0.0.1:10808)"
echo -e "${COLOR_BOLD}6. 清除代理并退出${COLOR_RESET}"

read proxy_choice

# 定义不走代理的域名列表
NO_PROXY_DOMAINS="dashscope.aliyuncs.com,*.aliyun.com,aliyun.com,*.aliyuncs.com,aliyuncs.com,zhihu.com,xiaohongshu.com,moonshot.cn,connected.bmw,searxng,atc.bmwgroup.net,api.sendcloud.net,bmw.com.cn,azure.com,.azure.com,.amazonaws.cn,amazonaws.cn,.amazonaws.com.cn,amazonaws.com.cn,bmwgroup.com,bmwgroup.net,.bmwgroup.com,127.0.0.1,localhost"

# 根据用户的选择来设置代理
case $proxy_choice in
    1)
        export ALL_PROXY="socks5://127.0.0.1:1080"
        export all_proxy="socks5://127.0.0.1:1080"
        ;;
    2)
        export HTTP_PROXY="http://127.0.0.1:4080"
        export http_proxy="http://127.0.0.1:4080"
        export HTTPS_PROXY="http://127.0.0.1:4080"
        export https_proxy="http://127.0.0.1:4080"
        ;;
    3)
        export HTTP_PROXY="http://127.0.0.1:3081"
        export http_proxy="http://127.0.0.1:3081"
        export HTTPS_PROXY="http://127.0.0.1:3081"
        export https_proxy="http://127.0.0.1:3081"
        ;;
    4)
        export ALL_PROXY="socks5://127.0.0.1:2080"
        export all_proxy="socks5://127.0.0.1:2080"
        ;;
    5)
        export HTTP_PROXY="http://127.0.0.1:10808"
        export http_proxy="http://127.0.0.1:10808"
        export HTTPS_PROXY="http://127.0.0.1:10808"
        export https_proxy="http://127.0.0.1:10808"
        ;;
    6)
        # unset_proxy 已经在脚本开始时运行过了
        echo -e "${COLOR_GREEN}代理已清除.${COLOR_RESET}"
        return 0
        ;;
    *)
        echo -e "${COLOR_RED}无效的选择.${COLOR_RESET}"
        return 1
        ;;
esac

# 仅在选择了有效代理时设置 no_proxy 并显示结果
if [[ "$proxy_choice" -ge 1 && "$proxy_choice" -le 5 ]]; then
    export no_proxy=$NO_PROXY_DOMAINS
    export NO_PROXY=$NO_PROXY_DOMAINS
    echo -e "
${COLOR_GREEN}代理设置已完成！当前代理配置如下：${COLOR_RESET}"
    env | grep -i proxy
    echo -e "
${COLOR_BOLD}${COLOR_YELLOW}重要提示: 要使配置在当前终端生效, 您需要 'source' 此脚本, 而不是直接运行它.${COLOR_RESET}"
    echo -e "${COLOR_YELLOW}例如: source ./simple_proxy_config_on_current_terminal.sh${COLOR_RESET}"
    echo -e "${COLOR_YELLOW}如需取消代理，请运行 'unset_proxy' 命令或关闭当前终端窗口.${COLOR_RESET}"
fi
