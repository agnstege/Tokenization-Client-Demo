FROM centos:7

ENV PATH="$PATH:/opt/mssql-tools18/bin"
ENV LD_LIBRARY_PATH=/opt/oracle/instantclient_21_7
ENV PATH=$PATH:$LD_LIBRARY_PATH
ENV PHP_DTRACE=yes
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY* \
  && yum -y install --setopt=install_weak_deps=False \
  epel-release \
  wget \
  && wget --no-check-certificate https://rpms.remirepo.net/enterprise/remi-release-7.rpm \
  && rpm -Uvh remi-release-7.rpm \
  && echo "67.219.148.138  mirrorlist.centos.org" >> /etc/hosts \
  && yum -y install --setopt=install_weak_deps=False \
  httpd \
  yum-utils \
  unzip \
  && yum-config-manager --enable remi-php74 \
  && yum -y install --setopt=install_weak_deps=False php \
  php-opcache \
  php-mysqlnd \
  php-pdo \
  php-gd \
  php-ldap \
  php-odbc \
  php-pear \
  php-xml \
  php-xmlrpc \
  php-mbstring \
  php-soap \
  curl \
  curl-devel \
  php-devel \
  unixODBC-devel \
  libaio.x86_64 \ 
  && pecl install sqlsrv-5.10.1 pdo_sqlsrv \
  && echo extension=pdo_sqlsrv.so >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/30-pdo_sqlsrv.ini \
  && echo extension=sqlsrv.so >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/20-sqlsrv.ini \
  && curl https://packages.microsoft.com/config/rhel/7/prod.repo > /etc/yum.repos.d/mssql-release.repo \
  && ACCEPT_EULA=Y yum -y install --setopt=install_weak_deps=False msodbcsql18 \
  && ACCEPT_EULA=Y yum -y install --setopt=install_weak_deps=False mssql-tools18 \
  && mkdir /opt/oracle \
  && wget -c https://download.oracle.com/otn_software/linux/instantclient/217000/instantclient-basiclite-linux.x64-21.7.0.0.0dbru.zip \
  && unzip instantclient-basiclite-linux.x64-21.7.0.0.0dbru.zip -d /opt/oracle \
  && wget -c https://download.oracle.com/otn_software/linux/instantclient/217000/instantclient-sdk-linux.x64-21.7.0.0.0dbru.zip \
  && unzip instantclient-sdk-linux.x64-21.7.0.0.0dbru.zip -d /opt/oracle \
  && yum -y install --setopt=install_weak_deps=False systemtap-sdt-devel \
  && echo "instantclient,/opt/oracle/instantclient_21_7" | pecl install oci8-2.2.0 \
  && echo extension=oci8.so >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/30-oci8.ini
ADD data/TokenApp_SQLSrv.zip data/TokenApp_MySQL.zip data/TokenApp_Oracle.zip data/info.php data/index.html data/setup.pdf /var/www/html/
ADD data/images /var/www/html/images
ADD data/style /var/www/html/style
RUN unzip /var/www/html/TokenApp_SQLSrv.zip -d /var/www/html \
  && unzip /var/www/html/TokenApp_MySQL.zip -d /var/www/html \
  && unzip /var/www/html/TokenApp_Oracle.zip -d /var/www/html \
  && chown -R apache:apache /var/www/html/* \
  && rm -rf /var/www/html/TokenApp_SQLSrv.zip /var/www/html/TokenApp_MySQL.zip /var/www/html/TokenApp_Oracle.zip \
  && rm instantclient-basiclite-linux.x64-21.7.0.0.0dbru.zip instantclient-sdk-linux.x64-21.7.0.0.0dbru.zip \
  && yum clean all

EXPOSE 80

CMD ["/sbin/httpd", "-DFOREGROUND"]
