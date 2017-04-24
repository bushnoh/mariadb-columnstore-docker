FROM centos:7

# additional dependencies for docker image
RUN curl -s https://packagecloud.io/install/repositories/imeyer/runit/script.rpm.sh | bash && yum -y update && yum -y install expect perl perl-DBI openssl zlib rsyslog libaio boost file sudo libnl net-tools sysvinit-tools perl-DBD-MySQL runit which psmisc lsof snappy wget && yum clean all

## add in files to the container for install
#ADD mariadb-columnstore-*-centos7.x86_64.rpm.tar.gz install.sh /install/

# install columnstore, you must copy mariadb-columnstore-<version>-centos7.x86_64.rpm.tar.gz into the directory
RUN mkdir /install/ \
 && wget -P /install/ https://downloads.mariadb.com/ColumnStore/1.0.8/centos/x86_64/7/mariadb-columnstore-1.0.8-1-centos7.x86_64.rpm.tar.gz \
 && export USER=root \
 && tar -xf /install/*.tar.gz -C /install/ \
 && yum localinstall -y /install/*.rpm \
 && rm -f /install/*.rpm /install/*.gz

# copy runit files
COPY service /etc/service/
COPY runit_bootstrap /usr/sbin/runit_bootstrap
ADD install.sh /install/
RUN chmod 755 /usr/sbin/runit_bootstrap

VOLUME /usr/local/mariadb/columnstore/data1
#VOLUME /usr/local/mariadb/columnstore/etc
VOLUME /usr/local/mariadb/columnstore/mysql/db

EXPOSE 3306

CMD ["/usr/sbin/runit_bootstrap"]
