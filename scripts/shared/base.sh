#!/usr/bin/env bash
echo "==> Base"

echo "==> libc6 issue workaround"
echo 'libc6 libraries/restart-without-asking boolean true' | sudo debconf-set-selections

function install_from_url {
  cd /tmp && {
    curl -sfLo "${1}.zip" "${2}"
    unzip -qq "${1}.zip"
    sudo mv "${1}" "/usr/local/bin/${1}"
    sudo chmod +x "/usr/local/bin/${1}"
    rm -rf "${1}.zip"
  }
}



echo "--> Setting iptables for bridge networking"
echo 1 > /proc/sys/net/bridge/bridge-nf-call-arptables
echo 1 > /proc/sys/net/bridge/bridge-nf-call-ip6tables
echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables

echo "--> Making iptables settings for bridge networking config change"
sudo tee /etc/sysctl.d/nomadtables > /dev/null <<EOF
net.bridge.bridge-nf-call-arptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

echo "--> updated version of Nodejs"
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -

echo "--> Installing common dependencies"
apt-get install -y \
  build-essential \
  nodejs \
  curl \
  emacs \
  git \
  jq \
  tmux \
  unzip \
  vim \
  wget \
  tree \
  nfs-kernel-server \
  nfs-common \
  python3-pip \
  ruby-full \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg-agent \
  software-properties-common \
  openjdk-14-jdk-headless \
  prometheus-node-exporter \
  &>/dev/null


echo "--> Disabling checkpoint"
sudo tee /etc/profile.d/checkpoint.sh > /dev/null <<"EOF"
export CHECKPOINT_DISABLE=1
EOF
source /etc/profile.d/checkpoint.sh



# echo "--> Installing dnsmasq"
# sudo apt-get install -y -q dnsmasq
#
# echo "--> Configuring DNSmasq"
# sudo tee /etc/dnsmasq.d/10-consul > /dev/null << EOF
# server=/consul/127.0.0.1#8600
# no-poll
# server=8.8.8.8
# server=8.8.4.4
# cache-size=0
# EOF

 # sudo systemctl enable dnsmasq
 # sudo systemctl restart dnsmasq

echo "--> Install Envoy"
curl -L https://getenvoy.io/cli | sudo bash -s -- -b /usr/local/bin
getenvoy run standard:1.14.2 -- --version
sudo cp ~/.getenvoy/builds/standard/1.14.2/linux_glibc/bin/envoy /usr/bin/

# curl -sL 'https://getenvoy.io/gpg' | sudo apt-key add -
# sudo add-apt-repository \
# "deb [arch=amd64] https://dl.bintray.com/tetrate/getenvoy-deb \
# $(lsb_release -cs) \
# stable"
# sudo apt-get update && sudo apt-get install -y getenvoy-envoy=1.14.1.p0.g3504d40-1p63.g902f20f

envoy --version

echo "==> Base is done!"
