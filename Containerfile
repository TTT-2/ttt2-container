FROM debian:buster-slim

ARG PUID=1000
ARG USER=steam
ARG HOME_DIR="/home/${USER}"

ARG STEAMCMD_DIR
ARG GMOD_DIR
ARG CSS_DIR
ARG GMOD_ADDON_DIR
ARG GMOD_CFG_DIR

# Do NOT set these environment variables when you create the container!
# If you wish to change them set the ARGs above before building the image.
ENV STEAMCMD_DIR="${STEAMCMD_DIR:-$HOME_DIR/steamcmd}"
ENV GMOD_DIR="${GMOD_DIR:-$HOME_DIR/gmod_ds}"
ENV CSS_DIR="${CSS_DIR:-$HOME_DIR/css_ds}"
ENV GMOD_ADDON_DIR="${GMOD_ADDON_DIR:-$HOME_DIR/gmod_addons}"
ENV GMOD_CFG_DIR="${GMOD_CFG_DIR:-$HOME_DIR/gmod_cfg}"

# Set to 'true' if you want steamcmd to validate
# your install once the container is run.
ENV CSS_VALIDATE="false"
ENV GMOD_VALIDATE="false"

# Set to whatever ports you want gmod to use.
ENV SV_PORT="27015"
ENV CL_PORT="27005"

ADD entrypoint.sh "${HOME_DIR}/entrypoint.sh"

# Download needed packages.
RUN set -x \
	&& dpkg --add-architecture i386 \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
		lib32stdc++6=8.3.0-6 \
		lib32gcc1=1:8.3.0-6 \
		wget=1.20.1-1.1 \
		ca-certificates=20190110 \
		libsdl2-2.0-0:i386=2.0.9+dfsg1-1 \
		libtinfo5:i386 \
	&& rm -rf /var/lib/apt/lists/*

# Create user.
RUN	set -x \
	&& useradd -u "${PUID}" -m "${USER}" \
	&& chown -R "${USER}:${USER}" "${HOME_DIR}/entrypoint.sh" "${HOME_DIR}"

# Download steamcmd and setup directories / symlinks.
RUN set -x \
    && su "${USER}" -c \
        "mkdir -p \"${STEAMCMD_DIR}\" \"${HOME_DIR}/.steam/sdk32\" \"${GMOD_DIR}\" \"${CSS_DIR}\" \"${GMOD_ADDON_DIR}\" \"${GMOD_CFG_DIR}\"\
        && wget -qO- 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz' | tar xvzf - -C \"${STEAMCMD_DIR}\" \
        && \"./${STEAMCMD_DIR}/steamcmd.sh\" +login anonymous +quit \
        && chmod +x \"${HOME_DIR}/entrypoint.sh\" \
        && ln -s \"${STEAMCMD_DIR}/linux32/steamclient.so\" \"${HOME_DIR}/.steam/sdk32/steamclient.so\""

# Switch to user.
USER ${USER}

VOLUME ["${GMOD_DIR}", "${CSS_DIR}", "${GMOD_ADDON_DIR}", "${GMOD_CFG_DIR}"]

WORKDIR ${HOME_DIR}

ENTRYPOINT ["bash", "entrypoint.sh"]

CMD ["+maxplayers 16", "+map gm_flatgrass"]
