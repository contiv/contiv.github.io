FROM ubuntu:16.04
RUN apt-get update && apt-get install -y git-core openssh-client curl wget \
 build-essential openssl libreadline6 libreadline6-dev curl zlib1g zlib1g-dev \
 libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev \
 autoconf libc6-dev ncurses-dev automake libtool bison pkg-config \
 gawk libgmp-dev libgdbm-dev libffi-dev
RUN curl -L https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm requirements"
RUN echo "gem: --no-document" >~/.gemrc
RUN /bin/bash -l -c "rvm install 2.0.0-p0"
RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc"
COPY . /sources
RUN cd /sources/websrc && bash -l -c "make init"
