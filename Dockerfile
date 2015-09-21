FROM centos:7.1.1503
MAINTAINER Wattana Inthaphong <wattaint@gmail.com>

RUN yum update -y \
&& yum install -y epel-release \
&& yum install -y make gcc gcc-c++ wget vim mlocate which tar bzip2 zip unzip \
&& rpm -iUvh http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-centos94-9.4-1.noarch.rpm \
&& yum install -y postgresql94 postgresql94-devel postgresql94-libs postgresql94-server postgresql94-plpython postgresql94-python postgresql94-python-debuginfo \
|| yum clean all

ENV PATH $PATH:/usr/pgsql-9.4/bin

### NODEJS #####################################################################

