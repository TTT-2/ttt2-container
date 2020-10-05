#!/bin/bash

# Install/update/validate css and gmod dedicated server
bash "${STEAMCMD_DIR}/steamcmd.sh" +login anonymous \
        +force_install_dir "${CSS_DIR}" +app_update 232330 $("${CSS_VALIDATE}" && echo 'validate')  \
        +force_install_dir "${GMOD_DIR}" +app_update 4020 $("${GMOD_VALIDATE}" && echo 'validate') \
        +quit

sed -i \
        -e "s|\"cstrike\"[[:space:]]*\".*\"|\"cstrike\" \"${CSS_DIR}/cstrike\"|" \
        -e 's|\/\/"cstrike"|"cstrike"|' \
        "${GMOD_DIR}/garrysmod/cfg/mount.cfg"

# Install a github repo (by default the masterbranch of ttt2 into gmods addons folder)
mkdir -p "${GMOD_DIR}/garrysmod/addons/${GIT_ADDON_DIR}" \
    && wget -qO - "https://github.com/${GIT_OWNER}/${GIT_REPO}/tarball/${GIT_REF}" \
    | tar xzf - -C "${GMOD_DIR}/garrysmod/addons/${GIT_ADDON_DIR}" --strip-components=1 --overwrite \
    || { echo "Download of Git repo failed"; exit 1; }

# Start the gmod server
bash "${GMOD_DIR}/srcds_run" \
        -console \
        -game garrysmod \
        -port "${SV_PORT}" \
        -clientport "${CL_PORT}" \
        -strictportbind \
        +gamemode terrortown \
        "$@"
