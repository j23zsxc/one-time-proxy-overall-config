## 我想写一款MACOS上运行的python脚本,实现以下功能. 所有内容请用中文给与回复
* echo "请选择您想要的功能: 1. 配置当前终端环境proxy 2. 配置MACOS系统proxy 3. 清除当前终端环境proxy 4.清除MACOS系统proxy "
# 如果选择1:
* echo"请选择您想配置的Proxy:"
1. NaiveProxy  Socks5:127.0.0.1:1080  
2. Juicity     HTTPS&Socks5:127.0.0.1:4080
3. Hysteria1   HTTPS:127.0.0.1:3081, Socks5:127.0.0.1:3080
4. Hysteria2   Socks5:127.0.0.1:2080

如果选择1:执行以下命令
export ALL_PROXY="socks://127.0.0.1:1080"
curl -v -k https://www.google.com
如果curl返回成功,echo "代理设置成功",否则 echo "代理配置失败,请检查配置"

如果选择2:
export HTTP_PROXY="http://127.0.0.1:4080"
export HTTPS_PROXY="http://127.0.0.1:4080"
curl -v -k https://www.google.com
如果curl返回成功,echo "代理设置成功",否则 echo "代理配置失败,请检查配置"

如果选择3:
export HTTP_PROXY="http://127.0.0.1:3081"
export HTTPS_PROXY="http://127.0.0.1:3081"
curl -v -k https://www.google.com
如果curl返回成功,echo "代理设置成功",否则 echo "代理配置失败,请检查配置"

如果选择4:
export ALL_PROXY="socks://127.0.0.1:2080"
curl -v -k https://www.google.com
如果curl返回成功,echo "代理设置成功",否则 echo "代理配置失败,请检查配置"


# 如果选择2:
* echo"请选择您想配置的Proxy:"
1.Juicity     HTTPS&Socks5:127.0.0.1:4080
2.Hysteria1   HTTPS:127.0.0.1:3081, Socks5:127.0.0.1:3080

如果选择1:
打开当前MACOS下无线网络的socks代理: 参考命令:networksetup -setsocksfirewallproxystate Wi-Fi on
将socks代理配置为127.0.0.1:4080
系统中执行curl -v -k https://www.google.com
如果curl返回成功,echo "代理设置成功",否则 echo "代理配置失败,请检查配置"

如果选择2:
打开当前MACOS下无线网络的HTTP和HTTPS代理:
将HTTP和HTTPS的代理都配置为127.0.0.1:3081
系统中执行curl -v -k https://www.google.com
如果curl返回成功,echo "代理设置成功",否则 echo "代理配置失败,请检查配置"


# 如果选择3:
关闭当前MACOS下无线网络的socks代理,但不清除配置
curl -v -k https://www.google.com
如果curl失败,echo "代理关闭成功",否则 echo "代理清除失败,请检查配置"

# 如果选择4:
关闭当前MACOS下无线网络的HTTP和HTTPS代理,但不清除配置
系统中执行curl -v -k https://www.google.com
如果curl失败,echo "代理关闭成功",否则 echo "代理清除失败,请检查配置"