#!/bin/bash

# Install/update/validate css and gmod dedicated server
bash "${STEAMCMD_DIR}/steamcmd.sh" +login anonymous \
        +force_install_dir "${CSS_DIR}" +app_update 232330 $("${CSS_VALIDATE}" && echo 'validate')  \
        +force_install_dir "${GMOD_DIR}" +app_update 4020 $("${GMOD_VALIDATE}" && echo 'validate') \
        +quit

# Make sure the addons directory is linked to the addons volume
if [[ ! -L "$GMOD_DIR/garrysmod/addons" ]];
then
        rm -d "${GMOD_DIR}/garrysmod/addons"
        ln -s "${GMOD_ADDON_DIR}" "${GMOD_DIR}/garrysmod/addons"
fi

# Make sure the cfg directory is linked to the cfg volume
if [[ ! -L "$GMOD_DIR/garrysmod/cfg" ]];
then
        # Make sure the cfg volume has at least the default cfg files
        mv -n "${GMOD_DIR}/garrysmod/cfg/"* "${GMOD_CFG_DIR}"
        rm -r "${GMOD_DIR}/garrysmod/cfg"
        ln -s "${GMOD_CFG_DIR}" "${GMOD_DIR}/garrysmod/cfg"
fi

# Make sure CS:S content is mounted
sed -i \
        -e "s|\"cstrike\"[[:space:]]*\".*\"|\"cstrike\" \"${CSS_DIR}/cstrike\"|" \
        -e 's|\/\/"cstrike"|"cstrike"|' \
        "${GMOD_CFG_DIR}/mount.cfg"

# Start the gmod server
bash "${GMOD_DIR}/srcds_run" \
        -console \
        -game garrysmod \
        -port "${SV_PORT}" \
        -clientport "${CL_PORT}" \
        -strictportbind \
        +gamemode terrortown \
        "$@"
