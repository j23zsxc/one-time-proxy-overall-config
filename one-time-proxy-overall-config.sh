#!/bin/zsh

# 颜色定义
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_BLUE='\033[0;34m'
COLOR_PURPLE='\033[0;35m'
COLOR_CYAN='\033[0;36m'
COLOR_BOLD='\033[1m'
COLOR_RESET='\033[0m'

# 定义 no_proxy 域名列表，实现抽象化
NO_PROXY_DOMAINS="dashscope.aliyuncs.com,*.aliyun.com,aliyun.com,*.aliyuncs.com,aliyuncs.com,zhihu.com,xiaohongshu.com,moonshot.cn,connected.bmw,searxng,atc.bmwgroup.net,api.sendcloud.net,bmw.com.cn,azure.com,.azure.com,.amazonaws.cn,amazonaws.cn,.amazonaws.com.cn,amazonaws.com.cn,bmwgroup.com,bmwgroup.net,.bmwgroup.com,127.0.0.1,localhost"

# 配置代理的函数
set_proxy() {
    local proxy_string=$1
    local proxy_type=$2

    # 将代理设置添加到 ~/.zshrc
    if [[ $proxy_type == "all" ]]; then
        echo "export ALL_PROXY=\"$proxy_string\"" >> ~/.zshrc
        echo "export all_proxy=\"$proxy_string\"" >> ~/.zshrc
        echo "export no_proxy=$NO_PROXY_DOMAINS" >> ~/.zshrc
        echo "export NO_PROXY=$NO_PROXY_DOMAINS" >> ~/.zshrc
    else
        echo "export HTTP_PROXY=\"$proxy_string\"" >> ~/.zshrc
        echo "export HTTPS_PROXY=\"$proxy_string\"" >> ~/.zshrc
        echo "export http_proxy=\"$proxy_string\"" >> ~/.zshrc
        echo "export https_proxy=\"$proxy_string\"" >> ~/.zshrc
        echo "export no_proxy=$NO_PROXY_DOMAINS" >> ~/.zshrc
        echo "export NO_PROXY=$NO_PROXY_DOMAINS" >> ~/.zshrc
    fi

    # 立即在当前会话中设置代理
    if [[ $proxy_type == "all" ]]; then
        export ALL_PROXY="$proxy_string"
        export all_proxy="$proxy_string"
        export no_proxy=$NO_PROXY_DOMAINS
        export NO_PROXY=$NO_PROXY_DOMAINS
    else
        export HTTP_PROXY="$proxy_string"
        export HTTPS_PROXY="$proxy_string"
        export http_proxy="$proxy_string"
        export https_proxy="$proxy_string"
        export no_proxy=$NO_PROXY_DOMAINS
        export NO_PROXY=$NO_PROXY_DOMAINS
    fi
}

# 清除代理设置
clear_proxy_settings() {
    # 从 ~/.zshrc 中移除代理设置
    sed -i '' '/export.*_proxy/Id' ~/.zshrc
    sed -i '' '/export.*PROXY/Id' ~/.zshrc

    # 清除当前会话的代理设置
    unset HTTP_PROXY HTTPS_PROXY ALL_PROXY http_proxy https_proxy all_proxy
}

# 测试代理是否工作的函数
test_proxy() {
    local test_type=$1
    local result=0

    case $test_type in
        "terminal")
            # 重新加载 zsh 配置
            source ~/.zshrc

            # 检查环境变量是否设置成功
            if env | grep -i proxy > /dev/null; then
                if curl -s -k --connect-timeout 5 https://www.google.com > /dev/null; then
                    echo -e "${COLOR_GREEN}终端代理配置成功${COLOR_RESET}"
                    echo -e "${COLOR_CYAN}当前代理设置:${COLOR_RESET}"
                    env | grep -i proxy
                    echo -e "\n${COLOR_YELLOW}注意: 请运行 'source ~/.zshrc' 或重新打开终端以使设置生效${COLOR_RESET}"
                    result=0
                else
                    echo -e "${COLOR_RED}终端代理连接测试失败,请检查代理服务是否正常运行${COLOR_RESET}"
                    result=1
                fi
            else
                echo -e "${COLOR_RED}终端代理环境变量设置失败${COLOR_RESET}"
                result=1
            fi
            ;;
        "system")
            # 检查系统代理设置
            local socks_enabled=$(networksetup -getsocksfirewallproxy Wi-Fi | grep "Enabled: Yes")
            local http_enabled=$(networksetup -getwebproxy Wi-Fi | grep "Enabled: Yes")
            local https_enabled=$(networksetup -getsecurewebproxy Wi-Fi | grep "Enabled: Yes")

            if [[ -n $socks_enabled || -n $http_enabled || -n $https_enabled ]]; then
                echo -e "${COLOR_GREEN}系统代理设置成功${COLOR_RESET}"
                echo -e "${COLOR_CYAN}当前系统代理设置:${COLOR_RESET}"
                echo -e "${COLOR_BLUE}HTTP代理设置:${COLOR_RESET}"
                networksetup -getwebproxy Wi-Fi
                echo -e "${COLOR_BLUE}HTTPS代理设置:${COLOR_RESET}"
                networksetup -getsecurewebproxy Wi-Fi
                echo -e "${COLOR_BLUE}SOCKS代理设置:${COLOR_RESET}"
                networksetup -getsocksfirewallproxy Wi-Fi
                result=0
            else
                echo -e "${COLOR_RED}系统代理设置失败${COLOR_RESET}"
                result=1
            fi
            ;;
    esac

    return $result
}

# 配置终端环境代理
configure_terminal_proxy() {
    echo -e "${COLOR_CYAN}请选择您想配置的Proxy:${COLOR_RESET}"
    echo -e "${COLOR_BOLD}1. NaiveProxy  ${COLOR_RESET}Socks5:127.0.0.1:1080"
    echo -e "${COLOR_BOLD}2. Juicity     ${COLOR_RESET}HTTPS&Socks5:127.0.0.1:4080"
    echo -e "${COLOR_BOLD}3. Hysteria1   ${COLOR_RESET}HTTPS:127.0.0.1:3081, Socks5:127.0.0.1:3080"
    echo -e "${COLOR_BOLD}4. Hysteria2   ${COLOR_RESET}Socks5:127.0.0.1:2080"
    echo -e "${COLOR_BOLD}5. v2rayN      ${COLOR_RESET}HTTPS:127.0.0.1:10808, HTTP:127.0.0.1:10808"

    read proxy_choice

    # 先清除现有代理设置
    clear_proxy_settings

    case $proxy_choice in
        1)
            set_proxy "socks5://127.0.0.1:1080" "all"
            test_proxy "terminal"
            ;;
        2)
            set_proxy "http://127.0.0.1:4080" "http"
            test_proxy "terminal"
            ;;
        3)
            set_proxy "http://127.0.0.1:3081" "http"
            test_proxy "terminal"
            ;;
        4)
            set_proxy "socks5://127.0.0.1:2080" "all"
            test_proxy "terminal"
            ;;
        5)
            set_proxy "http://127.0.0.1:10808" "http"
            test_proxy "terminal"
            ;;
        *)
            echo -e "${COLOR_RED}无效的选择${COLOR_RESET}"
            return 1
            ;;
    esac
}

# 读取 bypass_domains 文件
read_bypass_domains() {
    local bypass_file="$(dirname "$0")/bypass_domains.txt"

    # 检查文件是否存在
    if [[ ! -f "$bypass_file" ]]; then
        echo -e "${COLOR_RED}bypass_domains.txt 文件不存在，请确保文件存在于脚本同目录下${COLOR_RESET}"
        return 1
    fi

    # 确保该函数返回文件的每一行作为数组元素
    local domains=()
    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ -n "$line" ]]; then  # 忽略空行
            domains+=("$line")
        fi
    done < "$bypass_file"

    # 输出所有域名，一行一个
    printf "%s\n" "${domains[@]}"
}

# 配置系统代理
configure_system_proxy() {
    # 获取网络服务列表
    network_services=("Wi-Fi" "USB 10/100/1000 LAN")

    echo -e "${COLOR_CYAN}请选择您想配置的Proxy:${COLOR_RESET}"
    echo -e "${COLOR_BOLD}1. Juicity     ${COLOR_RESET}HTTPS&Socks5:127.0.0.1:4080"
    echo -e "${COLOR_BOLD}2. Hysteria1   ${COLOR_RESET}HTTPS:127.0.0.1:3081, Socks5:127.0.0.1:3080"
    echo -e "${COLOR_BOLD}3. v2rayN      ${COLOR_RESET}HTTPS:127.0.0.1:10808, HTTP:127.0.0.1:10808"

    read proxy_choice

    # 读取 bypass_domains
    # 存储域名到临时变量中，确保每行一个域名
    bypass_domains=($(read_bypass_domains))

    # 检查是否成功读取到域名
    if [[ ${#bypass_domains[@]} -eq 0 ]]; then
        echo -e "${COLOR_YELLOW}未能读取到绕过域名，将不设置绕过规则${COLOR_RESET}"
    else
        echo -e "${COLOR_PURPLE}已加载 $(echo ${#bypass_domains[@]}) 个绕过代理的域名${COLOR_RESET}"
    fi

    # 为每个网络服务配置代理
    for service in "${network_services[@]}"; do
        # 检查网络服务是否存在
        if ! networksetup -listallnetworkservices | grep -q "^${service}$"; then
            echo -e "${COLOR_YELLOW}${service} 网络服务不存在，跳过配置${COLOR_RESET}"
            continue
        fi

        # 先关闭所有代理
        networksetup -setwebproxystate "$service" off
        networksetup -setsecurewebproxystate "$service" off
        networksetup -setsocksfirewallproxystate "$service" off

        case $proxy_choice in
            1)
                echo -e "${COLOR_BLUE}正在配置 ${service} 的 Juicity 代理...${COLOR_RESET}"
                networksetup -setsocksfirewallproxy "$service" 127.0.0.1 4080
                networksetup -setsocksfirewallproxystate "$service" on
                ;;
            2)
                echo -e "${COLOR_BLUE}正在配置 ${service} 的 Hysteria1 代理...${COLOR_RESET}"
                networksetup -setwebproxy "$service" 127.0.0.1 3081
                networksetup -setsecurewebproxy "$service" 127.0.0.1 3081
                networksetup -setwebproxystate "$service" on
                networksetup -setsecurewebproxystate "$service" on
                ;;
            3)
                echo -e "${COLOR_BLUE}正在配置 ${service} 的 v2rayN 代理...${COLOR_RESET}"
                networksetup -setwebproxy "$service" 127.0.0.1 10808
                networksetup -setsecurewebproxy "$service" 127.0.0.1 10808
                networksetup -setwebproxystate "$service" on
                networksetup -setsecurewebproxystate "$service" on
                ;;
            *)
                echo -e "${COLOR_RED}无效的选择${COLOR_RESET}"
                return 1
                ;;
        esac

        # 设置绕过代理的域名（仅当成功读取到域名时）
        if [[ ${#bypass_domains[@]} -gt 0 ]]; then
            echo -e "${COLOR_BLUE}为 ${service} 配置绕过代理的域名...${COLOR_RESET}"
            networksetup -setproxybypassdomains "$service" "${bypass_domains[@]}"

            # 验证绕过域名是否设置成功
            local current_bypass=$(networksetup -getproxybypassdomains "$service")
            echo -e "${COLOR_CYAN}已设置 ${service} 绕过以下域名:${COLOR_RESET}"
            echo "$current_bypass"
        fi

        echo -e "${COLOR_GREEN}${service} 网络代理配置完成${COLOR_RESET}"
    done

    sleep 1
    test_proxy "system"

    echo -e "${COLOR_GREEN}所有网络接口的系统代理配置完成${COLOR_RESET}"
}

# 清除终端环境代理
clear_terminal_proxy() {
    clear_proxy_settings
    echo -e "${COLOR_GREEN}终端代理环境变量已清除${COLOR_RESET}"
    echo -e "${COLOR_YELLOW}请运行 'source ~/.zshrc' 或重新打开终端以使设置生效${COLOR_RESET}"
    env | grep -i proxy
}

# 清除系统代理
clear_system_proxy() {
    # 获取网络服务列表
    network_services=("Wi-Fi" "USB 10/100/1000 LAN")

    # 为每个网络服务配置代理
    for service in "${network_services[@]}"; do
        # 检查网络服务是否存在
        if ! networksetup -listallnetworkservices | grep -q "^${service}$"; then
            echo -e "${COLOR_YELLOW}${service} 网络服务不存在，跳过配置${COLOR_RESET}"
            continue
        fi

        # 关闭所有代理
        networksetup -setwebproxystate "$service" off
        networksetup -setsecurewebproxystate "$service" off
        networksetup -setsocksfirewallproxystate "$service" off

        echo -e "${COLOR_GREEN}已关闭 ${service} 的代理设置${COLOR_RESET}"

        # 显示当前代理状态
        echo -e "${COLOR_CYAN}-------------------${COLOR_RESET}"
        echo -e "${COLOR_BOLD}${service} 代理状态:${COLOR_RESET}"
        echo -e "${COLOR_BLUE}HTTP代理设置:${COLOR_RESET}"
        networksetup -getwebproxy "$service"
        echo -e "${COLOR_BLUE}HTTPS代理设置:${COLOR_RESET}"
        networksetup -getsecurewebproxy "$service"
        echo -e "${COLOR_BLUE}SOCKS代理设置:${COLOR_RESET}"
        networksetup -getsocksfirewallproxy "$service"
        echo -e "${COLOR_CYAN}-------------------${COLOR_RESET}"
    done

    echo -e "${COLOR_GREEN}所有系统代理已关闭${COLOR_RESET}"
}

# 主菜单
echo -e "${COLOR_BOLD}${COLOR_PURPLE}===== 代理配置工具 =====${COLOR_RESET}"
echo -e "${COLOR_CYAN}请选择您想要的功能:${COLOR_RESET}"
echo -e "${COLOR_BOLD}1. 配置当前终端环境proxy${COLOR_RESET}"
echo -e "${COLOR_BOLD}2. 配置MACOS系统proxy${COLOR_RESET}"
echo -e "${COLOR_BOLD}3. 清除当前终端环境proxy${COLOR_RESET}"
echo -e "${COLOR_BOLD}4. 清除MACOS系统proxy${COLOR_RESET}"

read choice

case $choice in
    1)
        configure_terminal_proxy
        echo -e "\n${COLOR_YELLOW}正在刷新终端环境...${COLOR_RESET}"
        exec zsh
        ;;
    2)
        configure_system_proxy
        ;;
    3)
        clear_terminal_proxy
        echo -e "\n${COLOR_YELLOW}正在刷新终端环境...${COLOR_RESET}"
        exec zsh
        ;;
    4)
        clear_system_proxy
        ;;
    *)
        echo -e "${COLOR_RED}无效的选择${COLOR_RESET}"
        exit 1
        ;;
esac


##!/bin/zsh
#
## 颜色定义
#COLOR_RED='\033[0;31m'
#COLOR_GREEN='\033[0;32m'
#COLOR_YELLOW='\033[0;33m'
#COLOR_BLUE='\033[0;34m'
#COLOR_PURPLE='\033[0;35m'
#COLOR_CYAN='\033[0;36m'
#COLOR_BOLD='\033[1m'
#COLOR_RESET='\033[0m'
#
## 定义 no_proxy 域名列表，实现抽象化
#NO_PROXY_DOMAINS="dashscope.aliyuncs.com,*.aliyun.com,aliyun.com,*.aliyuncs.com,aliyuncs.com,zhihu.com,xiaohongshu.com,moonshot.cn,connected.bmw,searxng,atc.bmwgroup.net,api.sendcloud.net,bmw.com.cn,azure.com,.azure.com,.amazonaws.cn,amazonaws.cn,.amazonaws.com.cn,amazonaws.com.cn,bmwgroup.com,bmwgroup.net,.bmwgroup.com,127.0.0.1,localhost"
#
## 配置代理的函数
#set_proxy() {
#    local proxy_string=$1
#    local proxy_type=$2
#
#    # 将代理设置添加到 ~/.zshrc
#    if [[ $proxy_type == "all" ]]; then
#        echo "export ALL_PROXY=\"$proxy_string\"" >> ~/.zshrc
#        echo "export all_proxy=\"$proxy_string\"" >> ~/.zshrc
#        echo "export no_proxy=$NO_PROXY_DOMAINS" >> ~/.zshrc
#        echo "export NO_PROXY=$NO_PROXY_DOMAINS" >> ~/.zshrc
#    else
#        echo "export HTTP_PROXY=\"$proxy_string\"" >> ~/.zshrc
#        echo "export HTTPS_PROXY=\"$proxy_string\"" >> ~/.zshrc
#        echo "export http_proxy=\"$proxy_string\"" >> ~/.zshrc
#        echo "export https_proxy=\"$proxy_string\"" >> ~/.zshrc
#        echo "export no_proxy=$NO_PROXY_DOMAINS" >> ~/.zshrc
#        echo "export NO_PROXY=$NO_PROXY_DOMAINS" >> ~/.zshrc
#    fi
#
#    # 立即在当前会话中设置代理
#    if [[ $proxy_type == "all" ]]; then
#        export ALL_PROXY="$proxy_string"
#        export all_proxy="$proxy_string"
#        export no_proxy=$NO_PROXY_DOMAINS
#        export NO_PROXY=$NO_PROXY_DOMAINS
#    else
#        export HTTP_PROXY="$proxy_string"
#        export HTTPS_PROXY="$proxy_string"
#        export http_proxy="$proxy_string"
#        export https_proxy="$proxy_string"
#        export no_proxy=$NO_PROXY_DOMAINS
#        export NO_PROXY=$NO_PROXY_DOMAINS
#    fi
#}
#
## 清除代理设置
#clear_proxy_settings() {
#    # 从 ~/.zshrc 中移除代理设置
#    sed -i '' '/export.*_proxy/Id' ~/.zshrc
#    sed -i '' '/export.*PROXY/Id' ~/.zshrc
#
#    # 清除当前会话的代理设置
#    unset HTTP_PROXY HTTPS_PROXY ALL_PROXY http_proxy https_proxy all_proxy
#}
#
## 测试代理是否工作的函数
#test_proxy() {
#    local test_type=$1
#    local result=0
#
#    case $test_type in
#        "terminal")
#            # 重新加载 zsh 配置
#            source ~/.zshrc
#
#            # 检查环境变量是否设置成功
#            if env | grep -i proxy > /dev/null; then
#                if curl -s -k --connect-timeout 5 https://www.google.com > /dev/null; then
#                    echo -e "${COLOR_GREEN}终端代理配置成功${COLOR_RESET}"
#                    echo -e "${COLOR_CYAN}当前代理设置:${COLOR_RESET}"
#                    env | grep -i proxy
#                    echo -e "\n${COLOR_YELLOW}注意: 请运行 'source ~/.zshrc' 或重新打开终端以使设置生效${COLOR_RESET}"
#                    result=0
#                else
#                    echo -e "${COLOR_RED}终端代理连接测试失败,请检查代理服务是否正常运行${COLOR_RESET}"
#                    result=1
#                fi
#            else
#                echo -e "${COLOR_RED}终端代理环境变量设置失败${COLOR_RESET}"
#                result=1
#            fi
#            ;;
#        "system")
#            # 检查系统代理设置
#            local socks_enabled=$(networksetup -getsocksfirewallproxy Wi-Fi | grep "Enabled: Yes")
#            local http_enabled=$(networksetup -getwebproxy Wi-Fi | grep "Enabled: Yes")
#            local https_enabled=$(networksetup -getsecurewebproxy Wi-Fi | grep "Enabled: Yes")
#
#            if [[ -n $socks_enabled || -n $http_enabled || -n $https_enabled ]]; then
#                echo -e "${COLOR_GREEN}系统代理设置成功${COLOR_RESET}"
#                echo -e "${COLOR_CYAN}当前系统代理设置:${COLOR_RESET}"
#                echo -e "${COLOR_BLUE}HTTP代理设置:${COLOR_RESET}"
#                networksetup -getwebproxy Wi-Fi
#                echo -e "${COLOR_BLUE}HTTPS代理设置:${COLOR_RESET}"
#                networksetup -getsecurewebproxy Wi-Fi
#                echo -e "${COLOR_BLUE}SOCKS代理设置:${COLOR_RESET}"
#                networksetup -getsocksfirewallproxy Wi-Fi
#                result=0
#            else
#                echo -e "${COLOR_RED}系统代理设置失败${COLOR_RESET}"
#                result=1
#            fi
#            ;;
#    esac
#
#    return $result
#}
#
## 配置终端环境代理
#configure_terminal_proxy() {
#    echo -e "${COLOR_CYAN}请选择您想配置的Proxy:${COLOR_RESET}"
#    echo -e "${COLOR_BOLD}1. NaiveProxy  ${COLOR_RESET}Socks5:127.0.0.1:1080"
#    echo -e "${COLOR_BOLD}2. Juicity     ${COLOR_RESET}HTTPS&Socks5:127.0.0.1:4080"
#    echo -e "${COLOR_BOLD}3. Hysteria1   ${COLOR_RESET}HTTPS:127.0.0.1:3081, Socks5:127.0.0.1:3080"
#    echo -e "${COLOR_BOLD}4. Hysteria2   ${COLOR_RESET}Socks5:127.0.0.1:2080"
#    echo -e "${COLOR_BOLD}5. v2rayN      ${COLOR_RESET}HTTPS:127.0.0.1:10808, HTTP:127.0.0.1:10808"
#
#    read proxy_choice
#
#    # 先清除现有代理设置
#    clear_proxy_settings
#
#    case $proxy_choice in
#        1)
#            set_proxy "socks5://127.0.0.1:1080" "all"
#            test_proxy "terminal"
#            ;;
#        2)
#            set_proxy "http://127.0.0.1:4080" "http"
#            test_proxy "terminal"
#            ;;
#        3)
#            set_proxy "http://127.0.0.1:3081" "http"
#            test_proxy "terminal"
#            ;;
#        4)
#            set_proxy "socks5://127.0.0.1:2080" "all"
#            test_proxy "terminal"
#            ;;
#        5)
#            set_proxy "http://127.0.0.1:10808" "http"
#            test_proxy "terminal"
#            ;;
#        *)
#            echo -e "${COLOR_RED}无效的选择${COLOR_RESET}"
#            return 1
#            ;;
#    esac
#}
#
## 读取 bypass_domains 文件
#read_bypass_domains() {
#    local bypass_file="$(dirname "$0")/bypass_domains.txt"
#
#    # 检查文件是否存在，不存在则创建默认内容
#    if [[ ! -f "$bypass_file" ]]; then
#        cat > "$bypass_file" << EOL
#localhost
#127.0.0.1
#*.office.com
#*.microsoftonline-p.net
#*.sfbassets.com
#*.sharepoint.com
#*.office.net
#*.outlook.com
#*.msocdn.com
#*.teams.microsoft.com
#teams.microsoft.com
#*.teams.live.com
#*.skype.com
#*.outlook.office.com
#*.outlook.office365.com
#outlook.live.com
#baidu.com
#bilibili.com
#qq.com
#zhihu.com
#xiaohongshu.com
#sina.com
#hupu.com
#youku.com
#iqiyi.com
#jd.com
#csdn.net
#aliyun.com
#ruciwan.com
#code.connected.bmw
#*.login.microsoftonline.com
#*.partner.bmwgroup.com
#*.events.data.microsoft.com
#*.kugou.com
#*.youdao.com
#*.sougou.com
#*.azure.com
#*.bmwgroup.net
#*.batechworks.com
#*.teams.cloud.microsoft
#*.cloud.microsoft
#*.apac.pptservicescast.officeapps.live.com
#*.i.manage.microsoft.com
#*.officeapps.live.com
#*.in.appcenter.ms
#*.api.sendcloud.net
#EOL
#        echo -e "${COLOR_YELLOW}已创建默认 bypass_domains.txt 文件${COLOR_RESET}"
#    fi
#
#    # 确保该函数返回文件的每一行作为数组元素
#    local domains=()
#    while IFS= read -r line || [[ -n "$line" ]]; do
#        if [[ -n "$line" ]]; then  # 忽略空行
#            domains+=("$line")
#        fi
#    done < "$bypass_file"
#
#    # 输出所有域名，一行一个
#    printf "%s\n" "${domains[@]}"
#}
#
## 配置系统代理
#configure_system_proxy() {
#    # 获取网络服务列表
#    network_services=("Wi-Fi" "USB 10/100/1000 LAN")
#
#    echo -e "${COLOR_CYAN}请选择您想配置的Proxy:${COLOR_RESET}"
#    echo -e "${COLOR_BOLD}1. Juicity     ${COLOR_RESET}HTTPS&Socks5:127.0.0.1:4080"
#    echo -e "${COLOR_BOLD}2. Hysteria1   ${COLOR_RESET}HTTPS:127.0.0.1:3081, Socks5:127.0.0.1:3080"
#    echo -e "${COLOR_BOLD}3. v2rayN      ${COLOR_RESET}HTTPS:127.0.0.1:10808, HTTP:127.0.0.1:10808"
#
#    read proxy_choice
#
#    # 读取 bypass_domains
#    # 存储域名到临时变量中，确保每行一个域名
#    bypass_domains=($(read_bypass_domains))
#
#    echo -e "${COLOR_PURPLE}已加载 $(echo ${#bypass_domains[@]}) 个绕过代理的域名${COLOR_RESET}"
#
#    # 为每个网络服务配置代理
#    for service in "${network_services[@]}"; do
#        # 检查网络服务是否存在
#        if ! networksetup -listallnetworkservices | grep -q "^${service}$"; then
#            echo -e "${COLOR_YELLOW}${service} 网络服务不存在，跳过配置${COLOR_RESET}"
#            continue
#        fi
#
#        # 先关闭所有代理
#        networksetup -setwebproxystate "$service" off
#        networksetup -setsecurewebproxystate "$service" off
#        networksetup -setsocksfirewallproxystate "$service" off
#
#        case $proxy_choice in
#            1)
#                echo -e "${COLOR_BLUE}正在配置 ${service} 的 Juicity 代理...${COLOR_RESET}"
#                networksetup -setsocksfirewallproxy "$service" 127.0.0.1 4080
#                networksetup -setsocksfirewallproxystate "$service" on
#                ;;
#            2)
#                echo -e "${COLOR_BLUE}正在配置 ${service} 的 Hysteria1 代理...${COLOR_RESET}"
#                networksetup -setwebproxy "$service" 127.0.0.1 3081
#                networksetup -setsecurewebproxy "$service" 127.0.0.1 3081
#                networksetup -setwebproxystate "$service" on
#                networksetup -setsecurewebproxystate "$service" on
#                ;;
#            3)
#                echo -e "${COLOR_BLUE}正在配置 ${service} 的 v2rayN 代理...${COLOR_RESET}"
#                networksetup -setwebproxy "$service" 127.0.0.1 10808
#                networksetup -setsecurewebproxy "$service" 127.0.0.1 10808
#                networksetup -setwebproxystate "$service" on
#                networksetup -setsecurewebproxystate "$service" on
#                ;;
#            *)
#                echo -e "${COLOR_RED}无效的选择${COLOR_RESET}"
#                return 1
#                ;;
#        esac
#
#        # 正确地设置绕过代理的域名
#        # 这里使用数组直接传入每个域名，确保每个域名被正确应用
#        echo -e "${COLOR_BLUE}为 ${service} 配置绕过代理的域名...${COLOR_RESET}"
#        networksetup -setproxybypassdomains "$service" "${bypass_domains[@]}"
#
#        # 验证绕过域名是否设置成功
#        local current_bypass=$(networksetup -getproxybypassdomains "$service")
#        echo -e "${COLOR_CYAN}已设置 ${service} 绕过以下域名:${COLOR_RESET}"
#        echo "$current_bypass"
#
#        echo -e "${COLOR_GREEN}${service} 网络代理配置完成${COLOR_RESET}"
#    done
#
#    sleep 1
#    test_proxy "system"
#
#    echo -e "${COLOR_GREEN}所有网络接口的系统代理配置完成，并已设置绕过代理的域名${COLOR_RESET}"
#}
#
## 清除终端环境代理
#clear_terminal_proxy() {
#    clear_proxy_settings
#    echo -e "${COLOR_GREEN}终端代理环境变量已清除${COLOR_RESET}"
#    echo -e "${COLOR_YELLOW}请运行 'source ~/.zshrc' 或重新打开终端以使设置生效${COLOR_RESET}"
#    env | grep -i proxy
#}
#
## 清除系统代理
#clear_system_proxy() {
#    # 获取网络服务列表
#    network_services=("Wi-Fi" "USB 10/100/1000 LAN")
#
#    # 为每个网络服务配置代理
#    for service in "${network_services[@]}"; do
#        # 检查网络服务是否存在
#        if ! networksetup -listallnetworkservices | grep -q "^${service}$"; then
#            echo -e "${COLOR_YELLOW}${service} 网络服务不存在，跳过配置${COLOR_RESET}"
#            continue
#        fi
#
#        # 关闭所有代理
#        networksetup -setwebproxystate "$service" off
#        networksetup -setsecurewebproxystate "$service" off
#        networksetup -setsocksfirewallproxystate "$service" off
#
#        echo -e "${COLOR_GREEN}已关闭 ${service} 的代理设置${COLOR_RESET}"
#
#        # 显示当前代理状态
#        echo -e "${COLOR_CYAN}-------------------${COLOR_RESET}"
#        echo -e "${COLOR_BOLD}${service} 代理状态:${COLOR_RESET}"
#        echo -e "${COLOR_BLUE}HTTP代理设置:${COLOR_RESET}"
#        networksetup -getwebproxy "$service"
#        echo -e "${COLOR_BLUE}HTTPS代理设置:${COLOR_RESET}"
#        networksetup -getsecurewebproxy "$service"
#        echo -e "${COLOR_BLUE}SOCKS代理设置:${COLOR_RESET}"
#        networksetup -getsocksfirewallproxy "$service"
#        echo -e "${COLOR_CYAN}-------------------${COLOR_RESET}"
#    done
#
#    echo -e "${COLOR_GREEN}所有系统代理已关闭${COLOR_RESET}"
#}
#
## 主菜单
#echo -e "${COLOR_BOLD}${COLOR_PURPLE}===== 代理配置工具 =====${COLOR_RESET}"
#echo -e "${COLOR_CYAN}请选择您想要的功能:${COLOR_RESET}"
#echo -e "${COLOR_BOLD}1. 配置当前终端环境proxy${COLOR_RESET}"
#echo -e "${COLOR_BOLD}2. 配置MACOS系统proxy${COLOR_RESET}"
#echo -e "${COLOR_BOLD}3. 清除当前终端环境proxy${COLOR_RESET}"
#echo -e "${COLOR_BOLD}4. 清除MACOS系统proxy${COLOR_RESET}"
#
#read choice
#
#case $choice in
#    1)
#        configure_terminal_proxy
#        echo -e "\n${COLOR_YELLOW}正在刷新终端环境...${COLOR_RESET}"
#        exec zsh
#        ;;
#    2)
#        configure_system_proxy
#        ;;
#    3)
#        clear_terminal_proxy
#        echo -e "\n${COLOR_YELLOW}正在刷新终端环境...${COLOR_RESET}"
#        exec zsh
#        ;;
#    4)
#        clear_system_proxy
#        ;;
#    *)
#        echo -e "${COLOR_RED}无效的选择${COLOR_RESET}"
#        exit 1
#        ;;
#esac
#
