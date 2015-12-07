FROM centos:7.1.1503
MAINTAINER Wattana Inthaphong <wattaint@gmail.com>

RUN yum update -y \
&& yum install -y epel-release \
&& yum install -y make gcc gcc-c++ wget vim mlocate which tar bzip2 zip unzip telnet net-tools \
&& rpm -iUvh http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-centos94-9.4-1.noarch.rpm \
&& yum install -y\
  postgresql94-9.4.5-1PGDG.rhel7.x86_64\
  postgresql94-devel-9.4.5-1PGDG.rhel7.x86_64\
  postgresql94-libs-9.4.5-1PGDG.rhel7.x86_64\
  postgresql94-plpython-9.4.5-1PGDG.rhel7.x86_64\
  postgresql94-python-4.1.1-2PGDG.rhel7.x86_64\
  postgresql94-python-debuginfo-4.1.1-2PGDG.rhel7.x86_64\
  postgresql94-server-9.4.5-1PGDG.rhel7.x86_64 \
|| yum clean all

RUN yum install -y ruby ruby-devel \
&& gem install bundler \
|| yum clean all

### NODE.JS #####################################################################
ENV NODE_VERSION v4.2.3
RUN wget https://nodejs.org/dist/$NODE_VERSION/node-$NODE_VERSION.tar.gz \
&& tar -xf node-$NODE_VERSION.tar.gz \
&& cd node-$NODE_VERSION \
&& ./configure \
&& make \
&& make install \
&& cd / \
&& rm -rf node-$NODE_VERSION \
&& rm -f node-$NODE_VERSION.tar.gz

###########################################################################
RUN npm install -g coffee-script mocha nodemon