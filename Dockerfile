FROM ubuntu:24.04

ARG USERNAME=hluser
ARG USER_UID=10000
ARG USER_GID=$USER_UID

# create custom user, install dependencies, create data directory
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update -y && apt-get install curl -y \
    && mkdir -p /home/$USERNAME/hl/data && chown -R $USERNAME:$USERNAME /home/$USERNAME/hl


RUN apt-get update && \
  apt-get install -y nginx && \
  chown -R $USERNAME:$USERNAME /var/lib/nginx && \
  chown -R $USERNAME:$USERNAME /var/log/nginx && \
  chmod a+w /run && \
  echo "\ndaemon off;\nerror_log /dev/stdout info;" >> /etc/nginx/nginx.conf && \
  sed -e "s/^.*access_log.*$/access_log \/dev\/stdout;/" /etc/nginx/nginx.conf


USER $USERNAME

WORKDIR /home/$USERNAME

COPY hl-evm.conf /etc/nginx/sites-available/default
COPY entrypoint.sh /entrypoint.sh

# configure chain to testnet
RUN echo '{"chain": "Testnet"}' > /home/$USERNAME/visor.json

# save the public list of peers to connect to
ADD --chown=$USER_UID:$USER_GID https://binaries.hyperliquid.xyz/Testnet/initial_peers.json /home/$USERNAME/initial_peers.json

# temporary configuration file (will not be required in future update)
ADD --chown=$USER_UID:$USER_GID https://binaries.hyperliquid.xyz/Testnet/non_validator_config.json /home/$USERNAME/non_validator_config.json

# add the binary
ADD --chown=$USER_UID:$USER_GID --chmod=700 https://binaries.hyperliquid.xyz/Testnet/hl-visor /home/$USERNAME/hl-visor

# evm rpc port
EXPOSE 8001
# gossip ports
EXPOSE 4001
EXPOSE 4002

# run a non-node
CMD ["/entrypoint.sh"]
