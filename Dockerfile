FROM nlknguyen/alpine-mpich:latest

USER root

# # ------------------------------------------------------------
# # Miscellaneous setup for better user experience
# # ------------------------------------------------------------

# Set welcome message to display when user ssh login 
COPY welcome.txt /etc/motd

# Default working directory when user ssh login 
RUN echo "cd $WORKDIR" >> ${HOME}/.profile

# Utility program for listing nodes' IP addresses
COPY get_hosts /usr/local/bin/
RUN chmod +x /usr/local/bin/get_hosts

# Automatically create hostfile when user login
RUN echo "get_hosts > hosts" >> ${HOME}/.profile


# # ------------------------------------------------------------
# # Set up SSH Server 
# # ------------------------------------------------------------

# Add host keys
RUN cd /etc/ssh/ && ssh-keygen -A -N ''

# Config SSH Daemon
RUN  sed -i "s/#PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config \
          && sed -i "s/#PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config \
          && sed -i "s/#AuthorizedKeysFile/AuthorizedKeysFile/g" /etc/ssh/sshd_config
 
# Unlock non-password USER to enable SSH login
RUN passwd -u ${USER}

# Set up user's public and private keys
ENV SSHDIR ${HOME}/.ssh
RUN mkdir -p ${SSHDIR}

ONBUILD COPY ssh/ ${SSHDIR}/

ONBUILD USER root
ONBUILD RUN cat ${SSHDIR}/*.pub >> ${SSHDIR}/authorized_keys
ONBUILD RUN chmod -R 600 ${SSHDIR}/* \
         && chown -R ${USER}:${USER} ${SSHDIR}

# # ------------------------------------------------------------
# # Switch back to default user when continue the build process
# # ------------------------------------------------------------
ONBUILD USER ${USER}
