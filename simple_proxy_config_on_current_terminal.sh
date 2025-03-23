#!/bin/zsh

# 代理服务器地址和端口
PROXY_HOST="127.0.0.1"
PROXY_PORT="4080"
PROXY_URL="http://$PROXY_HOST:$PROXY_PORT"

# 设置代理环境变量
export http_proxy="$PROXY_URL"
export HTTP_PROXY="$PROXY_URL"
export https_proxy="$PROXY_URL"
export HTTPS_PROXY="$PROXY_URL"

# 设置不走代理的地址
export no_proxy="bmw.com.cn,azure.com,.azure.com,.amazonaws.cn,amazonaws.cn,.amazonaws.com.cn,amazonaws.com.cn,bmwgroup.com,.bmwgroup.com,127.0.0.1,localhost"
export NO_PROXY="bmw.com.cn,azure.com,.azure.com,.amazonaws.cn,amazonaws.cn,.amazonaws.com.cn,amazonaws.com.cn,bmwgroup.com,.bmwgroup.com,127.0.0.1,localhost"

# 显示当前代理设置
echo "代理设置已完成！当前代理配置如下："
echo "http_proxy  = $http_proxy"
echo "https_proxy = $https_proxy"
echo "no_proxy    = $no_proxy"
echo ""
echo "提示：这些设置仅对当前终端窗口有效"
echo "如需取消代理，请运行 unset_proxy 命令或关闭当前终端窗口"

# 定义一个取消代理的函数
function unset_proxy() {
    unset http_proxy
    unset HTTP_PROXY
    unset https_proxy
    unset HTTPS_PROXY
    unset no_proxy
    unset NO_PROXY
    echo "已清除所有代理设置"
}

# 将取消代理的函数导出到当前shell环境
export -f unset_proxy