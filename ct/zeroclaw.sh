#!/usr/bin/env bash
# Engine comes from community-scripts/core; this repo only ships the scripts.
# A local core checkout wins (COMMUNITY_SCRIPTS_CORE_DIR, else a sibling ../core),
# so a fork or branch of core can be tested without editing this file.
_cs_boot="${COMMUNITY_SCRIPTS_CORE_DIR:-$(dirname "${BASH_SOURCE[0]}")/../../core}/core/build.func"
source "$_cs_boot" 2>/dev/null || source <(curl -fsSL "${COMMUNITY_SCRIPTS_CORE_URL:-https://raw.githubusercontent.com/community-scripts/core/main}/core/build.func")

# Copyright (c) 2021-2026 community-scripts ORG
# Author: Juan Lago (juanparati)
# License: MIT | https://github.com/community-scripts/ProxmoxVED/raw/main/LICENSE
# Source: https://github.com/zeroclaw-labs/zeroclaw

APP="ZeroClaw"
var_tags="${var_tags:-ai;agent;automation}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-1024}"
var_disk="${var_disk:-4}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_arm64="${var_arm64:-yes}"
var_unprivileged="${var_unprivileged:-1}"
var_testurl="${var_testurl:-https://github.com/community-scripts/ProxmoxVED/issues/NNNN}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  if [[ ! -f /opt/zeroclaw/zeroclaw ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  if check_for_gh_release "zeroclaw-bin" "zeroclaw-labs/zeroclaw"; then
    msg_info "Stopping Service"
    systemctl stop zeroclaw
    msg_ok "Stopped Service"

    CLEAN_INSTALL=1 fetch_and_deploy_gh_release "zeroclaw-bin" "zeroclaw-labs/zeroclaw" "prebuild" "latest" "/opt/zeroclaw" \
      "zeroclaw-$(arch_resolve x86_64-unknown-linux-gnu aarch64-unknown-linux-gnu).tar.gz"
    chmod +x /opt/zeroclaw/zeroclaw

    msg_info "Starting Service"
    systemctl start zeroclaw
    msg_ok "Started Service"
    msg_ok "Updated successfully!"
  fi
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW}Access the gateway using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:42617${CL}"
