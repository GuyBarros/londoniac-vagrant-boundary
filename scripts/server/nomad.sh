

echo "--> Waiting for Vault leader"
while ! host active.vault.service.consul &> /dev/null; do
  sleep 5
done

echo "--> Generating Vault token..."
export VAULT_TOKEN="$(consul kv get service/vault/root-token)"
export NOMAD_VAULT_TOKEN="$(VAULT_TOKEN="$VAULT_TOKEN" \
  VAULT_ADDR="http://active.vault.service.consul:8200" \
  VAULT_SKIP_VERIFY=true \
  vault token create -field=token -policy=superuser -policy=nomad-server -display-name=nserver-1 -id=nserver-1 -period=72h)"

consul kv put service/vault/nserver-1-token $NOMAD_VAULT_TOKEN


echo "--> Create a Directory to Use as a Mount Target"
sudo mkdir -p /opt/mysql/data/
sudo mkdir -p /opt/mongodb/data/
sudo mkdir -p /opt/prometheus/data/
sudo mkdir -p /opt/shared/data/
sudo chmod 777 /opt/mysql/data/
sudo chmod 777 /opt/mongodb/data/
sudo chmod 777 /opt/prometheus/data/
sudo chmod 777 /opt/shared/data/

echo "--> Installing CNI plugin"
sudo mkdir -p /opt/cni/bin/
wget -O cni.tgz http://github.com/containernetworking/plugins/releases/download/v0.8.6/cni-plugins-linux-amd64-v0.8.6.tgz
sudo tar -xzf cni.tgz -C /opt/cni/bin/


echo "--> Writing configuration"
sudo mkdir -p /mnt/nomad
sudo mkdir -p /etc/nomad.d
sudo tee /etc/nomad.d/config.hcl > /dev/null <<EOF
data_dir     = "/mnt/nomad"
enable_debug = true
region = "global"
datacenter = "dc1"
server {
  enabled          = true
  bootstrap_expect = 1
  encrypt          = "NGUzM2VjYmI3MGM5ZGJiODcxM2FhODAzMDM1MDhlYmU="
}
client {
  enabled = true
  # network_interface = "eth0"
   options {
    "driver.raw_exec.enable" = "1"
     "docker.privileged.enabled" = "true"
  }
  meta {
    "type" = "server"
  }
  host_volume "mysql_mount" {
    path      = "/opt/mysql/data/"
    read_only = false
  }
  host_volume "mongodb_mount" {
    path      = "/opt/mongodb/data/"
    read_only = false
  }
  host_volume "prometheus_mount" {
    path      = "/opt/prometheus/data/"
    read_only = false
  }

  host_volume "shared_mount" {
    path      = "/opt/shared/data/"
    read_only = false
  }

}
tls {
  rpc  = false
  http = false
  verify_server_hostname = false
}
consul {
    address = "localhost:8500"
    server_service_name = "nomad-server"
    client_service_name = "nomad-client"
    auto_advertise = true
    server_auto_join = true
    client_auto_join = true
}
vault {
  enabled          = true
  address          = "http://active.vault.service.consul:8200"
  create_from_role = "nomad-cluster"
}
autopilot {
    cleanup_dead_servers = true
    last_contact_threshold = "200ms"
    max_trailing_logs = 250
    server_stabilization_time = "10s"
    enable_redundancy_zones = false
    disable_upgrade_migration = false
    enable_custom_upgrades = false
}
telemetry {
  publish_allocation_metrics = true
  publish_node_metrics = true
  prometheus_metrics = true
}
EOF

echo "--> Writing profile"
sudo tee /etc/profile.d/nomad.sh > /dev/null <<"EOF"
alias noamd="nomad"
alias nomas="nomad"
alias nomda="nomad"
export NOMAD_ADDR="http://EU-guystack-server-1.node.consul:4646"
export NOMAD_CACERT="/usr/local/share/ca-certificates/01-me.crt"
export NOMAD_CLIENT_CERT="/etc/ssl/certs/me.crt"
export NOMAD_CLIENT_KEY="/etc/ssl/certs/me.key"
EOF
source /etc/profile.d/nomad.sh

echo "--> Generating systemd configuration"
sudo tee /etc/systemd/system/nomad.service > /dev/null <<EOF
[Unit]
Description=Nomad
Documentation=http://www.nomadproject.io/docs/
Requires=network-online.target
After=network-online.target

[Service]
Environment=VAULT_TOKEN=$NOMAD_VAULT_TOKEN
ExecStart=nomad agent -bind '{{ GetInterfaceIP "eth2" }}' -config="/vagrant/scripts/"
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGINT
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

 sudo systemctl enable nomad
 sudo systemctl start nomad
sleep 5

echo "==> Nomad is done!"

echo "==> IPs :"
ip addr show | grep -o "inet [0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*"

