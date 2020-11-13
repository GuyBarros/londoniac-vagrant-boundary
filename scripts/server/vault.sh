
#!/usr/bin/env bash
echo "==> Vault (server)"


echo "--> Writing configuration"
sudo mkdir -p /etc/vault.d
sudo tee /etc/vault.d/config.hcl > /dev/null <<EOF
cluster_name = "demostack"
storage "consul" {
  path = "vault/"
  service = "vault"
}
listener "tcp" {
  address       = "0.0.0.0:8200"
   tls_disable = true
   tls-skip-verify = true
}
seal "transit" {
  address            = "http://192.168.1.152:8200"
  token              = "s.wrlHqUffYHZNY9IGJXUf3cbT"
  disable_renewal    = "true"

  // Key configuration
  key_name           = "unseal"
  mount_path         = "transit/"
  namespace          = "boundary/"
}

telemetry {
  prometheus_retention_time = "30s",
  disable_hostname = true
}

replication {
      resolver_discover_servers = false
}

disable_mlock = true
ui = true
EOF

echo "--> Writing profile"
sudo tee /etc/profile.d/vault.sh > /dev/null <<"EOF"
alias vualt="vault"
export VAULT_ADDR="http://active.vault.service.consul:8200"
EOF
source /etc/profile.d/vault.sh

echo "--> Generating systemd configuration"
sudo tee /etc/systemd/system/vault.service > /dev/null <<"EOF"
[Unit]
Description=Vault
Documentation=http://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target
[Service]
Restart=on-failure
ExecStart=vault server -config="/etc/vault.d/config.hcl"
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGINT
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable vault
sudo systemctl start vault
sleep 8




echo "==> Vault is done!"