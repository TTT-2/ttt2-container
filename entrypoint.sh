#!/bin/bash

# Install/update/validate css and gmod dedicated server
bash "${STEAMCMD_DIR}/steamcmd.sh" +login anonymous \
        +force_install_dir "${CSS_DIR}" +app_update 232330 $("${CSS_VALIDATE}" && echo 'validate')  \
        +force_install_dir "${GMOD_DIR}" +app_update 4020 $("${GMOD_VALIDATE}" && echo 'validate') \
        +quit

# Install a github repo (by default the masterbranch of ttt2 into gmods addons folder)
mkdir -p "${GIT_TARGET_DIR}" \
    && wget -qO - "${GIT_URL}" \
    | tar xzf - -C "${GIT_TARGET_DIR}" --strip-components=1 \
    || { echo "Download of Git repo failed"; exit 1; }

# Start the gmod server
bash "${GMOD_DIR}/srcds_run" \
        -console \
        -game garrysmod \
        +gamemode terrortown \
        "$@"
