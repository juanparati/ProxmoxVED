#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: Juan Lago (juanparati)
# License: MIT | https://github.com/community-scripts/ProxmoxVED/raw/main/LICENSE
# Source: https://github.com/zeroclaw-labs/zeroclaw

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt install -y \
  libnss3 \
  libatk1.0-0 \
  libcups2
msg_ok "Installed Dependencies"

fetch_and_deploy_gh_release "zeroclaw" "zeroclaw-labs/zeroclaw" "prebuild" "latest" "/opt/zeroclaw" \
  "zeroclaw-$(arch_resolve x86_64-unknown-linux-gnu aarch64-unknown-linux-gnu).tar.gz"
chmod +x /opt/zeroclaw/zeroclaw
ln -sf /opt/zeroclaw/zeroclaw /usr/local/bin/zeroclaw

msg_info "Configuring ZeroClaw"
mkdir -p /opt/zeroclaw_data/zeroclaw
cat <<EOF >/opt/zeroclaw_data/zeroclaw/config.toml
[gateway]
host = "0.0.0.0"
port = 42617
allow_public_bind = true

[storage]
path = "/opt/zeroclaw_data"
EOF
msg_ok "Configured ZeroClaw"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/zeroclaw.service
[Unit]
Description=ZeroClaw AI Agent Runtime
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/zeroclaw_data
Environment=XDG_CONFIG_HOME=/opt/zeroclaw_data
Environment=ZEROCLAW_HOME=/opt/zeroclaw_data
ExecStart=/opt/zeroclaw/zeroclaw daemon
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now zeroclaw
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
