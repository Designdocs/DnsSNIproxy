## 自用

### 快速安装（推荐）：
``` Bash
wget --no-check-certificate -O dns.sh https://raw.githubusercontent.com/Designdocs/DnsSNIproxy/main/dns.sh && bash dns.sh -f
```

### 普通安装：
``` Bash
wget --no-check-certificate -O dns.sh https://raw.githubusercontent.com/Designdocs/DnsSNIproxy/main/dns.sh && bash dns.sh -i
```

### 卸载方法：
``` Bash
wget --no-check-certificate -O dns.sh https://raw.githubusercontent.com/Designdocs/DnsSNIproxy/main/dns.sh && bash dns.sh -u
```

### 使用方法：
将代理主机的 DNS 地址设置为安装了 dnsmasq 的主机 IP 即可，如果遇到问题，尝试在配置文件中只保留一个 DNS 地址。

为了防止滥用，建议不要公开 IP 地址，并使用防火墙进行适当的访问限制。

### 调试排错：
- 确认 sniproxy 运行状态

  查看sniproxy状态：`systemctl status sniproxy`

  如果 sniproxy 未运行，请检查是否有其他服务占用了 80、443 端口，导致端口冲突。可以使用 `netstat -tlunp | grep 443` 命令查看端口监听情况。

- 确认防火墙设置

  确保防火墙已放行 53、80、443 端口。在调试时，可以关闭防火墙： `systemctl stop firewalld.service`

  对于阿里云、腾讯云、AWS 等云服务提供商，安全组的端口设置同样需要放行。
  
  使用其他服务器进行测试： `telnet 1.2.3.4 53` 

- 域名解析测试

  在配置完 DNS 后，进行域名解析测试：`nslookup netflix.com` 检查 IP 是否为 Netflix 代理服务器的 IP。
  如果系统中没有 nslookup 命令，可以在 CentOS 上安装：`yum install -y bind-utils` 在 Ubuntu 和 Debian 上安装：`apt-get -y install dnsutils`

- 解决 systemd-resolve 服务占用 53 端口的问题
  
  使用 `netstat -tlunp | grep 53` 发现 53 端口被 systemd-resolved 占用
  修改`/etc/systemd/resolved.conf`文件：
  ```
  [Resolve]
  DNS=8.8.8.8 1.1.1.1 #取消注释，增加dns
  #FallbackDNS=
  #Domains=
  #LLMNR=no
  #MulticastDNS=no
  #DNSSEC=no
  #Cache=yes
  DNSStubListener=no  #取消注释，把yes改为no
  ```
  然后执行以下命令，并重启 systemd-resolved 服务：
  ```
  ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
  systemctl restart systemd-resolved.service
  ```


**在 dnsmasq_sniproxy_install 项目基础上二次开发**：https://github.com/Designdocs/DnsSNIproxy
