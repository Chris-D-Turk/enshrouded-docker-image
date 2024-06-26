FROM debian:12-slim

ARG CONTAINER_GID=10000
ARG CONTAINER_UID=10000

ENV DEBIAN_FRONTEND "noninteractive"
ENV STEAM_APP_ID "2278520"
ENV HOME "/home/steam"
ENV STEAM_PATH "/home/steam/Steam"
ENV ENSHROUDED_PATH "/home/steam/enshrouded"
ENV ENSHROUDED_CONFIG "${ENSHROUDED_PATH}/enshrouded_server.json"
ENV GE_PROTON_VERSION "8-30"
ENV GE_PROTON_URL "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton${GE_PROTON_VERSION}/GE-Proton${GE_PROTON_VERSION}.tar.gz"
ENV STEAM_COMPAT_CLIENT_INSTALL_PATH "$STEAM_PATH"
ENV STEAM_COMPAT_DATA_PATH "${STEAM_PATH}/steamapps/compatdata/${STEAM_APP_ID}"
ENV ULWGL_ID 0

RUN groupadd -g $CONTAINER_GID steam \
    && useradd -g $CONTAINER_GID -u $CONTAINER_UID -m steam \
    && sed -i 's#^Components: .*#Components: main non-free contrib#g' /etc/apt/sources.list.d/debian.sources \
    && echo steam steam/question select "I AGREE" | debconf-set-selections \
    && echo steam steam/license note '' | debconf-set-selections \
    && dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        procps \
        ca-certificates \
        winbind \
        dbus \
        libfreetype6 \
        curl \
        wget \
        jq \
        locales \
        lib32gcc-s1 \
        steamcmd \
        zip \
        vim \
        nodejs \
        npm \
    && wget https://mega.nz/linux/repo/Debian_12/amd64/megacmd-Debian_12_amd64.deb \
    && apt install "$PWD/megacmd-Debian_12_amd64.deb" -y \
    && wget https://dmej8g5cpdyqd.cloudfront.net/downloads/noip-duc_3.0.0.tar.gz \
    && tar xf noip-duc_3.0.0.tar.gz \
    && apt install ./noip-duc_3.0.0/binaries/noip-duc_3.0.0_amd64.deb \
    && ln -s /usr/games/steamcmd /usr/bin/steamcmd \
    && echo 'LANG="en_US.UTF-8"' > /etc/default/locale \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen \
    && rm -f /etc/machine-id \
    && dbus-uuidgen --ensure=/etc/machine-id \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && apt-get autoremove -y

RUN mkdir "$HOME/.npm" \
    && chown -R 10000:10000 "$HOME/.npm"

USER steam

# RUN steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir "$ENSHROUDED_PATH" +login anonymous +app_update ${STEAM_APP_ID} validate +quit

RUN mkdir "$ENSHROUDED_PATH" \
    && mkdir -p "${ENSHROUDED_PATH}/savegame" \
    && mkdir -p "${STEAM_PATH}/compatibilitytools.d" \
    && mkdir -p "${STEAM_PATH}/steamapps/compatdata/${STEAM_APP_ID}" \
    && mkdir -p "${HOME}/.steam" \
    && steamcmd +quit \
    && ln -s "${HOME}/.local/share/Steam/steamcmd/linux32" "${HOME}/.steam/sdk32" \
    && ln -s "${HOME}/.local/share/Steam/steamcmd/linux64" "${HOME}/.steam/sdk64" \
    && ln -s "${HOME}/.steam/sdk32/steamclient.so" "${HOME}/.steam/sdk32/steamservice.so" \
    && ln -s "${HOME}/.steam/sdk64/steamclient.so" "${HOME}/.steam/sdk64/steamservice.so" \
    && wget "$GE_PROTON_URL" -O "/home/steam/GE-Proton${GE_PROTON_VERSION}.tgz" \
    && tar -x -C "${STEAM_PATH}/compatibilitytools.d/" -f "/home/steam/GE-Proton${GE_PROTON_VERSION}.tgz" \
    && rm "/home/steam/GE-Proton${GE_PROTON_VERSION}.tgz"
    
COPY entrypoint.sh "$HOME/entrypoint.sh"
COPY enshrouded-server-env.sh "$HOME/enshrouded-server-env.sh"
COPY idlekiller.sh "$HOME/idlekiller.sh"
COPY enshrouded_server_example.json "$HOME/enshrouded_server_example.json"

RUN mkdir "$HOME/playercount" \
    && cd "$HOME/playercount" \
    && npm install gamedig 
COPY playercount.js "$HOME/playercount/playercount.js"

WORKDIR $HOME

CMD ["/home/steam/entrypoint.sh"]
