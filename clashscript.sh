#!/bin/bash

# 获取最新版本的 release 信息
release_info=$(curl --fail -s https://api.github.com/repos/Dreamacro/clash/releases/latest)
if [ $? -ne 0 ]; then
  echo "获取 clash release 信息失败！"
  exit 1
fi

# 从 release 信息中提取 assets 信息 排序输出
assets_name=$(echo "$release_info" | jq -r '.assets[].name')
assets_url=$(echo "$release_info" | jq -r '.assets[].browser_download_url')
sorted_assets=$(echo "$assets_name" | awk '{print NR " " $1}')


echo "最新版本适配平台如下："
echo "$sorted_assets"


# 获取 assets 列表的长度
assets_count=$(echo "$assets_name" | wc -l)

# 输入要下载的 assets 的序号
read -p "请输入下载序号：" asset_index

# 检测用户输入的 assets 序号是否合法
if [ $asset_index -lt 1 -o $asset_index -gt $assets_count ]; then
  echo "输入的序号不合法！"
  exit 1
fi

asset_name=$(echo "$assets_name" | sed -n "${asset_index}p")
asset_url=$(echo "$assets_url" | sed -n "${asset_index}p")
echo "正在获取 $asset_name ..."



asset_url=${asset_url/github.com/download.fastgit.org}
echo "$asset_url"
# curl -L "$asset_url" -o "$asset_name"
# wget -c "$asset_url" -O "$asset_name"
echo "下载完成！"



# 获取最新版本的 release 信息
# Country_mmdb_info=$(curl --fail -s https://api.github.com/repos/Dreamacro/maxmind-geoip/releases/latest)
# if [ $? -ne 0 ]; then
#   echo "获取 Country mmdb 信息失败！"
#   exit 1
# fi

# Country_mmdb_url=$(echo "$Country_mmdb_info" | jq -r '.assets[].browser_download_url')
# Country_mmdb_url=${Country_mmdb_url/github.com/download.fastgit.org}
# echo "$Country_mmdb_url"
# # 下载到home目录下
# # curl -o ~/Country.mmdb -O "$Country_mmdb_url"

# curl "$Country_mmdb_url" -o ~/Country.mmdb --connect-timeout 10 --retry 3 --retry-delay 5 --http1.1



# # 解压文件
# tar -zxvf "$asset_name"

# # 为下载的文件添加可执行权限
# chmod +x "$asset_name"

function open_proxy(){
    export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"
    export http_proxy="http://127.0.0.1:7890"
    export https_proxy=$http_proxy
    echo -e "Proxy On"
}
# set HTTP_PROXY=http://127.0.0.1:7890 win
# set HTTPS_PROXY=http://127.0.0.1:7890
function close_proxy(){
    unset http_proxy
    unset https_proxy
    echo -e "Proxy Off"
}
