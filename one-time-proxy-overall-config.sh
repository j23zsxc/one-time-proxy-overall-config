#!/bin/zsh

# 配置代理的函数
set_proxy() {
    local proxy_string=$1
    local proxy_type=$2

    # 将代理设置添加到 ~/.zshrc
    if [[ $proxy_type == "all" ]]; then
        echo "export ALL_PROXY=\"$proxy_string\"" >> ~/.zshrc
        echo "export all_proxy=\"$proxy_string\"" >> ~/.zshrc
        echo "export no_proxy=bmw.com.cn,azure.com,.azure.com,.amazonaws.cn,amazonaws.cn,.amazonaws.com.cn,amazonaws.com.cn,bmwgroup.com,.bmwgroup.com,127.0.0.1,localhost" >> ~/.zshrc
        echo "export NO_PROXY=bmw.com.cn,azure.com,.azure.com,.amazonaws.cn,amazonaws.cn,.amazonaws.com.cn,amazonaws.com.cn,bmwgroup.com,.bmwgroup.com,127.0.0.1,localhost" >> ~/.zshrc
    else
        echo "export HTTP_PROXY=\"$proxy_string\"" >> ~/.zshrc
        echo "export HTTPS_PROXY=\"$proxy_string\"" >> ~/.zshrc
        echo "export http_proxy=\"$proxy_string\"" >> ~/.zshrc
        echo "export https_proxy=\"$proxy_string\"" >> ~/.zshrc
        echo "export no_proxy=bmw.com.cn,azure.com,.azure.com,.amazonaws.cn,amazonaws.cn,.amazonaws.com.cn,amazonaws.com.cn,bmwgroup.com,.bmwgroup.com,127.0.0.1,localhost" >> ~/.zshrc
        echo "export NO_PROXY=bmw.com.cn,azure.com,.azure.com,.amazonaws.cn,amazonaws.cn,.amazonaws.com.cn,amazonaws.com.cn,bmwgroup.com,.bmwgroup.com,127.0.0.1,localhost" >> ~/.zshrc
    fi

    # 立即在当前会话中设置代理
    if [[ $proxy_type == "all" ]]; then
        export ALL_PROXY="$proxy_string"
        export all_proxy="$proxy_string"
        export no_proxy=bmw.com.cn,azure.com,.azure.com,.amazonaws.cn,amazonaws.cn,.amazonaws.com.cn,amazonaws.com.cn,bmwgroup.com,.bmwgroup.com,127.0.0.1,localhost
        export NO_PROXY=bmw.com.cn,azure.com,.azure.com,.amazonaws.cn,amazonaws.cn,.amazonaws.com.cn,amazonaws.com.cn,bmwgroup.com,.bmwgroup.com,127.0.0.1,localhost
    else
        export HTTP_PROXY="$proxy_string"
        export HTTPS_PROXY="$proxy_string"
        export http_proxy="$proxy_string"
        export https_proxy="$proxy_string"
        export no_proxy=bmw.com.cn,azure.com,.azure.com,.amazonaws.cn,amazonaws.cn,.amazonaws.com.cn,amazonaws.com.cn,bmwgroup.com,.bmwgroup.com,127.0.0.1,localhost
        export NO_PROXY=bmw.com.cn,azure.com,.azure.com,.amazonaws.cn,amazonaws.cn,.amazonaws.com.cn,amazonaws.com.cn,bmwgroup.com,.bmwgroup.com,127.0.0.1,localhost
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
                    echo "终端代理配置成功"
                    echo "当前代理设置:"
                    env | grep -i proxy
                    echo "\n注意: 请运行 'source ~/.zshrc' 或重新打开终端以使设置生效"
                    result=0
                else
                    echo "终端代理连接测试失败,请检查代理服务是否正常运行"
                    result=1
                fi
            else
                echo "终端代理环境变量设置失败"
                result=1
            fi
            ;;
        "system")
            # 检查系统代理设置
            local socks_enabled=$(networksetup -getsocksfirewallproxy Wi-Fi | grep "Enabled: Yes")
            local http_enabled=$(networksetup -getwebproxy Wi-Fi | grep "Enabled: Yes")
            local https_enabled=$(networksetup -getsecurewebproxy Wi-Fi | grep "Enabled: Yes")

            if [[ -n $socks_enabled || -n $http_enabled || -n $https_enabled ]]; then
                echo "系统代理设置成功"
                echo "当前系统代理设置:"
                echo "HTTP代理设置:"
                networksetup -getwebproxy Wi-Fi
                echo "HTTPS代理设置:"
                networksetup -getsecurewebproxy Wi-Fi
                echo "SOCKS代理设置:"
                networksetup -getsocksfirewallproxy Wi-Fi
                result=0
            else
                echo "系统代理设置失败"
                result=1
            fi
            ;;
    esac

    return $result
}

# 配置终端环境代理
configure_terminal_proxy() {
    echo "请选择您想配置的Proxy:"
    echo "1. NaiveProxy  Socks5:127.0.0.1:1080"
    echo "2. Juicity     HTTPS&Socks5:127.0.0.1:4080"
    echo "3. Hysteria1   HTTPS:127.0.0.1:3081, Socks5:127.0.0.1:3080"
    echo "4. Hysteria2   Socks5:127.0.0.1:2080"

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
        *)
            echo "无效的选择"
            return 1
            ;;
    esac
}

# 配置系统代理
configure_system_proxy() {
    # 获取网络服务列表
    network_services=("Wi-Fi" "USB 10/100/1000 LAN")

    echo "请选择您想配置的Proxy:"
    echo "1. Juicity     HTTPS&Socks5:127.0.0.1:4080"
    echo "2. Hysteria1   HTTPS:127.0.0.1:3081, Socks5:127.0.0.1:3080"

    read proxy_choice

    # 为每个网络服务配置代理
    for service in "${network_services[@]}"; do
        # 检查网络服务是否存在
        if ! networksetup -listallnetworkservices | grep -q "^${service}$"; then
            echo "${service} 网络服务不存在，跳过配置"
            continue
        fi

        # 先关闭所有代理
        networksetup -setwebproxystate "$service" off
        networksetup -setsecurewebproxystate "$service" off
        networksetup -setsocksfirewallproxystate "$service" off

        case $proxy_choice in
            1)
                echo "正在配置 ${service} 的 Juicity 代理..."
                networksetup -setsocksfirewallproxy "$service" 127.0.0.1 4080
                networksetup -setsocksfirewallproxystate "$service" on
                ;;
            2)
                echo "正在配置 ${service} 的 Hysteria1 代理..."
                networksetup -setwebproxy "$service" 127.0.0.1 3081
                networksetup -setsecurewebproxy "$service" 127.0.0.1 3081
                networksetup -setwebproxystate "$service" on
                networksetup -setsecurewebproxystate "$service" on
                ;;
            *)
                echo "无效的选择"
                return 1
                ;;
        esac

        bypass_domains=(
            "localhost"
            "127.0.0.1"
            "*.office.com"
            "*.microsoftonline-p.net"
            "*.sfbassets.com"
            "*.sharepoint.com"
            "*.office.net"
            "*.outlook.com"
            "*.msocdn.com"
            "*.teams.microsoft.com"
            "teams.microsoft.com"
            "*.teams.live.com"
            "*.skype.com"
            "*.outlook.office.com"
            "*.outlook.office365.com"
            "outlook.live.com"
            "baidu.com"
            "bilibili.com"
            "qq.com"
            "zhihu.com"
            "xiaohongshu.com"
            "sina.com"
            "hupu.com"
            "youku.com"
            "iqiyi.com"
            "jd.com"
            "csdn.net"
            "aliyun.com"
            "ruciwan.com"
            "code.connected.bmw"
            "*.login.microsoftonline.com"
            "*.partner.bmwgroup.com"
            "*.events.data.microsoft.com"
            "*.kugou.com"
            "*.youdao.com"
            "*.sougou.com"
            "*.azure.com"
            "*.bmwgroup.net"
            "*.batechworks.com"
            "*.teams.cloud.microsoft"
            "*.cloud.microsoft"
            "*.apac.pptservicescast.officeapps.live.com"
            "*.i.manage.microsoft.com"
            "*.officeapps.live.com"
            "*.in.appcenter.ms"

        )

        # 配置绕过代理的域名
        networksetup -setproxybypassdomains "$service" "${bypass_domains[@]}"

        echo "${service} 网络代理配置完成"
    done

    sleep 1
    test_proxy "system"

    echo "所有网络接口的系统代理配置完成，并已设置绕过代理的域名"
}

# 清除终端环境代理
clear_terminal_proxy() {
    clear_proxy_settings
    echo "终端代理环境变量已清除"
    echo "请运行 'source ~/.zshrc' 或重新打开终端以使设置生效"
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
            echo "${service} 网络服务不存在，跳过配置"
            continue
        fi

        # 关闭所有代理
        networksetup -setwebproxystate "$service" off
        networksetup -setsecurewebproxystate "$service" off
        networksetup -setsocksfirewallproxystate "$service" off

        echo "已关闭 ${service} 的代理设置"

        # 显示当前代理状态
        echo "-------------------"
        echo "${service} 代理状态:"
        echo "HTTP代理设置:"
        networksetup -getwebproxy "$service"
        echo "HTTPS代理设置:"
        networksetup -getsecurewebproxy "$service"
        echo "SOCKS代理设置:"
        networksetup -getsocksfirewallproxy "$service"
        echo "-------------------"
    done

    echo "所有系统代理已关闭"
}

# 主菜单
echo "请选择您想要的功能:"
echo "1. 配置当前终端环境proxy"
echo "2. 配置MACOS系统proxy"
echo "3. 清除当前终端环境proxy"
echo "4. 清除MACOS系统proxy"

read choice

case $choice in
    1)
        configure_terminal_proxy
        echo "\n正在刷新终端环境..."
        exec zsh
        ;;
    2)
        configure_system_proxy
        ;;
    3)
        clear_terminal_proxy
        echo "\n正在刷新终端环境..."
        exec zsh
        ;;
    4)
        clear_system_proxy
        ;;
    *)
        echo "无效的选择"
        exit 1
        ;;
esac