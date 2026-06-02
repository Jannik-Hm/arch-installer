#!/bin/bash
# stage 95-dotfiles — clone the user's dotfiles and run the setup script.
#
# Opt-out (DOTFILES_ENABLED=0 to skip).
#
# Config keys (set in stage 10 / defaults.env):
#   DOTFILES_REPO         — git repository URL to clone
#   DOTFILES_SETUP_SCRIPT — setup script path relative to the clone directory

set -Eeuo pipefail
# shellcheck source=../lib/common.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/common.sh"
# shellcheck source=../lib/config.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/config.sh"

main() {
    cfg_load
    cfg_require USERNAME

    if [[ "${DOTFILES_ENABLED:-1}" != "1" ]]; then
        log_info "dotfiles disabled — skipping"
        return 0
    fi

    cfg_require DOTFILES_REPO DOTFILES_SETUP_SCRIPT

    local home="/home/${USERNAME}"
    local clone_dir
    clone_dir="$(basename "${DOTFILES_REPO}" .git)"

    run sudo -u "$USERNAME" git clone \
        "${DOTFILES_REPO}" \
        --recursive \
        "${home}/${clone_dir}"
    log_info "dotfiles cloned to ${home}/${clone_dir}"

    run sudo -u "$USERNAME" "${home}/${clone_dir}/${DOTFILES_SETUP_SCRIPT}"
    log_info "dotfiles setup script completed"

    log_info "dotfiles stage complete"
}

main "$@"
