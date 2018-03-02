
# custom-centos7
FROM openshift/base-centos7

# TODO: Put the maintainer name in the image metadata
MAINTAINER Andrea Finessi  <andrea.finessi@euris.it>

# TODO: Rename the builder environment variable to inform users about application you provide them
 ENV BUILDER_VERSION 1.0

# TODO: Set labels used in OpenShift to describe the builder image
LABEL io.k8s.description="Platform for php56 and OCI8 and client Oracle 11.2" \
      io.k8s.display-name="builder custom php56-OCI8-OracleClient11.2" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,php,oracle"

# TODO: Install required packages here:
# RUN yum install -y ... && yum clean all -y
#RUN yum install -y rubygems && yum clean all -y
#RUN gem install asdf

RUN   yum -y install epel-release --nogpgcheck
RUN   rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm


# -----------------------------------------------------------------------------
# Apache + (PHP 5.6 from https://webtatic.com)
# -----------------------------------------------------------------------------


RUN  yum --setopt=tsflags=nodocs -y update && \
     yum --setopt=tsflags=nodocs -y install \
        httpd \
        php56w \
        php56w-common \
        php56w-devel \
        php56w-mysql \
        php56w-mbstring \
        php56w-soap \
        php56w-gd \
        php56w-ldap \
        php56w-mssql \
        php56w-pear \
        php56w-pdo \
        php56w-intl \
        php56w-xml \
        php56w-pecl-xdebug \
        libaio

RUN yum clean all

RUN yum install gcc && yum clean all



#Install Oracle Client And OCI8


ADD ./oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm /tmp
ADD ./oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.rpm /tmp

RUN rpm -Uvh /tmp/oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm
RUN rpm -Uvh /tmp/oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.rpm

RUN echo "/usr/lib/oracle/11.2/client64/lib" > /etc/ld.so.conf.d/oracle.conf

RUN echo 'instantclient,/usr/lib/oracle/11.2/client64/lib' | pecl install oci8-2.0.12


#Settings Apache conf and php.ini

RUN sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf
RUN sed -i 's/#ServerName.*/ServerName localhost/' /etc/httpd/conf/httpd.conf
RUN sed -i 's/\[OCI8\]/[OCI8]\nextension=oci8.so\nextension_dir=\/usr\/lib64\/php\/modules\n/' /etc/php.ini



# TODO (optional): Copy the builder files into /opt/app-root
# COPY ./<builder_folder>/ /opt/app-root/

# TODO: Copy the S2I scripts to /usr/libexec/s2i, since openshift/base-centos7 image
# sets io.openshift.s2i.scripts-url label that way, or update that label
COPY ./s2i/bin/ /usr/libexec/s2i

# TODO: Drop the root user and make the content of /opt/app-root owned by user 1001
RUN chown -R 1001:1001 /opt/app-root

RUN chmod -R a+rwx /etc/httpd/conf
RUN chmod -R a+rwx /etc/httpd/conf.d
RUN chmod -R a+rwx /etc/httpd/logs
RUN chown -R 1001:0 /etc/httpd/logs
RUN chmod -R a+rwx /etc/php.d
RUN chmod -R a+rwx /etc/php.ini
RUN chown -R 1001:0 /etc/php.d
RUN chown -R 1001:0 /etc/php.ini
RUN chmod -R a+rwx /var/run/httpd
RUN chmod -R a+rwx /var/lib/php/session
RUN chown -R 1001:0 /var/lib/php/session
RUN chmod -R a+rwx /var/www/
RUN chown -R 1001:0 /var/www/




# This default user is created in the openshift/base-centos7 image
USER 1001

# TODO: Set the default port for applications built using this image
EXPOSE 8080

# TODO: Set the default CMD for the image
# CMD ["/usr/libexec/s2i/usage"]
