FROM r-base:3.5.3

ARG CONTAINER_PROJECT_FOLDER
ENV TZ America/New_York

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# System setup
RUN apt-get update && apt-get install -y --no-install-recommends \
       apt-transport-https ca-certificates gnupg \
    && sh -c 'echo "deb http://cran.rstudio.com/bin/linux/ubuntu bionic-cran35/" >> /etc/apt/sources.list' \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 \
    && apt-get update && apt-get install -y --no-install-recommends \
        python3-pip libpython3-dev python3-dev python3-setuptools \
        bash vim-tiny build-essential locales \
        gosu \
    && rm -rf /var/lib/apt/lists/*

# R package dependencies
RUN apt-get update && apt-get install -y \
    libcurl4 libcurl4-openssl-dev libmagick++-dev \
    && rm -rf /var/lib/apt/lists/*

# Set the locale
RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8 

# App setup
WORKDIR ${CONTAINER_PROJECT_FOLDER}
# install app specific packages
COPY ./required/requirements.R /root
RUN Rscript /root/requirements.R

COPY ./required/requirements.txt /root
RUN pip3 install --no-cache-dir wheel \
	&& pip3 install --no-cache-dir -r /root/requirements.txt

