FROM nlknguyen/alpine-mpich:latest

# # ------------------------------------------------------------
# # Set up SSH Server 
# # ------------------------------------------------------------
ONBUILD USER root

# Add host keys
ONBUILD RUN cd /etc/ssh/ && ssh-keygen -A -N ''

# Config SSH Daemon
ONBUILD RUN  sed -i "s/#PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config \
          && sed -i "s/#PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config \
          && sed -i "s/#AuthorizedKeysFile/AuthorizedKeysFile/g" /etc/ssh/sshd_config
 
# Unlock non-password USER to enable SSH login
ONBUILD RUN passwd -u ${USER}

# Set up user's public and private keys
ONBUILD ENV SSHDIR ${HOME}/.ssh
ONBUILD RUN mkdir -p ${SSHDIR}

ONBUILD COPY ssh/ ${SSHDIR}/
ONBUILD RUN cat ${SSHDIR}/*.pub >> ${SSHDIR}/authorized_keys

ONBUILD RUN chmod -R 600 ${SSHDIR}/* \
         && chown -R ${USER}:${USER} ${SSHDIR}

# # ------------------------------------------------------------
# # Miscellaneous setup for user experience
# # ------------------------------------------------------------

# Set welcome message to display when user login 
COPY welcome.txt /etc/motd

# Default working directory when user login 
ONBUILD RUN echo "cd $WORKDIR" >> ${HOME}/.profile

# Utility for listing nodes' IP addresses
COPY get_hosts /usr/local/bin/
RUN chmod +x /usr/local/bin/get_hosts

# Automatically create hostfile when user login
ONBUILD RUN echo "get_hosts > hosts" >> ${HOME}/.profile


# # ------------------------------------------------------------
# # Switch back to default user when continue the build process
# # ------------------------------------------------------------
ONBUILD USER ${USER}
