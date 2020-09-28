FROM debian:buster-slim

ARG PUID=1000

ENV USER=steam
ENV HOME_DIR="/home/${USER}"
ENV STEAMCMD_DIR="${HOME_DIR}/steamcmd"
ENV GMOD_DIR="${HOME_DIR}/gmod_ds"
ENV CSS_DIR="${HOME_DIR}/css_ds"

ENV CSS_VALIDATE="false"
ENV GMOD_VALIDATE="false"

ENV SV_PORT="27015"
ENV CL_PORT="27005"

ENV GIT_OWNER="TTT-2"
ENV GIT_REPO="TTT2"
ENV GIT_REF="master"
ENV GIT_URL="https://github.com/${GIT_OWNER}/${GIT_REPO}/archive/${GIT_REF}.tar.gz"
ENV GIT_TARGET_DIR="${ADDON_DIR}/ttt2"

ADD entrypoint.sh "${HOME_DIR}/entrypoint.sh"

# Download needed packages
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

# Create steam user
RUN	set -x \
	&& useradd -u "${PUID}" -m "${USER}" \
	&& chown -R "${USER}:${USER}" "${HOME_DIR}/entrypoint.sh" "${HOME_DIR}"

# Download steamcmd and setup directories / symlinks
RUN set -x \
    && su "${USER}" -c \
        "mkdir -p \"${STEAMCMD_DIR}\" \"${HOME_DIR}/.steam/sdk32\" \"${GMOD_DIR}\" \"${CSS_DIR}\" \
        && wget -qO- 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz' | tar xvzf - -C \"${STEAMCMD_DIR}\" \
        && \"./${STEAMCMD_DIR}/steamcmd.sh\" +login anonymous +quit \
        && chmod +x \"${HOME_DIR}/entrypoint.sh\" \
        && ln -s \"${STEAMCMD_DIR}/linux32/steamclient.so\" \"${HOME_DIR}/.steam/sdk32/steamclient.so\""

# Switch to steam user
USER ${USER}

VOLUME ["${GMOD_DIR}", "${CSS_DIR}"]

WORKDIR ${HOME_DIR}

ENTRYPOINT ["bash", "entrypoint.sh"]

CMD ["+maxplayers 16", "+map gm_flatgrass"]
