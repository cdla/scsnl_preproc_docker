FROM ubuntu:xenial

MAINTAINER Carlo de los Angeles <Carlo.delosangeles@gmail.com>
# spm portion based on official spm docker image
# neurodebian portion based from official neurodebian xenial image

RUN apt-get update && \
    apt-get install -y unzip xorg wget && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install MATLAB MCR in /opt/mcr/
ENV MATLAB_VERSION R2018b
ENV MCR_VERSION v95
RUN mkdir /opt/mcr_install && \
    mkdir /opt/mcr && \
    wget -P /opt/mcr_install https://www.mathworks.com/supportfiles/downloads/${MATLAB_VERSION}/deployment_files/${MATLAB_VERSION}/installers/glnxa64/MCR_${MATLAB_VERSION}_glnxa64_installer.zip && \
    unzip -q /opt/mcr_install/MCR_${MATLAB_VERSION}_glnxa64_installer.zip -d /opt/mcr_install && \
    /opt/mcr_install/install -destinationFolder /opt/mcr -agreeToLicense yes -mode silent && \
    rm -rf /opt/mcr_install /tmp/*

# Install SPM Standalone in /opt/spm12/
ENV SPM_VERSION 12
ENV SPM_REVISION r7487
ENV LD_LIBRARY_PATH /opt/mcr/${MCR_VERSION}/runtime/glnxa64:/opt/mcr/${MCR_VERSION}/bin/glnxa64:/opt/mcr/${MCR_VERSION}/sys/os/glnxa64:/opt/mcr/${MCR_VERSION}/sys/opengl/lib/glnxa64
ENV MCR_INHIBIT_CTF_LOCK 1
RUN wget --no-check-certificate -P /opt https://www.fil.ion.ucl.ac.uk/spm/download/restricted/bids/spm${SPM_VERSION}_${SPM_REVISION}_Linux_${MATLAB_VERSION}.zip && \
    unzip -q /opt/spm${SPM_VERSION}_${SPM_REVISION}_Linux_${MATLAB_VERSION}.zip -d /opt && \
    rm -f /opt/spm${SPM_VERSION}_${SPM_REVISION}_Linux_${MATLAB_VERSION}.zip && \
    /opt/spm${SPM_VERSION}/spm${SPM_VERSION} function exit


# Add neurodebian repository
RUN set -x \
	&& apt-get update \
	&& { \
		which gpg \
		|| apt-get install -y --no-install-recommends gnupg \
	; } \
# Ubuntu includes "gnupg" (not "gnupg2", but still 2.x), but not dirmngr, and gnupg 2.x requires dirmngr
# so, if we're not running gnupg 1.x, explicitly install dirmngr too
	&& { \
		gpg --version | grep -q '^gpg (GnuPG) 1\.' \
		|| apt-get install -y --no-install-recommends dirmngr \
	; } \
	&& rm -rf /var/lib/apt/lists/*

# apt-key is a bit finicky during "docker build" with gnupg 2.x, so install the repo key the same way debian-archive-keyring does (/etc/apt/trusted.gpg.d)
# this makes "apt-key list" output prettier too!
RUN set -x \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys DD95CC430502E37EF840ACEEA5D32F012649A5A9 \
	&& gpg --export DD95CC430502E37EF840ACEEA5D32F012649A5A9 > /etc/apt/trusted.gpg.d/neurodebian.gpg \
	&& rm -rf "$GNUPGHOME" \
	&& apt-key list | grep neurodebian

# Install FSL
RUN apt-get update && \
apt-get install -y -qq --no-install-recommends fsl-core
ENV FSLDIR=/usr/share/fsl/5.0 \
FSLOUTPUTTYPE=NIFTI_GZ \
FSLMULTIFILEQUIT=TRUE \
POSSUMDIR=/usr/share/fsl/5.0 \
LD_LIBRARY_PATH=/usr/lib/fsl/5.0:$LD_LIBRARY_PATH \
FSLTCLSH=/usr/bin/tclsh \
FSLWISH=/usr/bin/wish \
PATH=/usr/lib/fsl/5.0:$PATH

RUN apt-get clean && \
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /boot /media /mnt /srv
