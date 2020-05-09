FROM amazonlinux:2017.03.1.20170812

# Update packages and install needed compilation dependencies
RUN yum update -y
RUN yum clean all
RUN yum install glibc tar gzip make autoconf bison gcc gcc-c++ libcurl-devel libxml2-devel -y

# Compile OpenSSL v1.0.1 from source, as Amazon Linux uses a newer version than the Lambda Execution Environment, which
# would otherwise produce an incompatible binary.
RUN curl -sL http://www.openssl.org/source/openssl-1.0.1k.tar.gz | tar -xvz
WORKDIR /openssl-1.0.1k
RUN ./config && make && make install

WORKDIR /var/build


# Download the PHP 7.3.0 source
RUN mkdir /var/build/php-7-bin
RUN curl -sL https://github.com/php/php-src/archive/php-7.3.0.tar.gz | tar -xvz
WORKDIR /var/build/php-src-php-7.3.0

# Compile PHP 7.3.0 with OpenSSL 1.0.1 support, and install to /home/ec2-user/php-7-bin
RUN ./buildconf --force
RUN ./configure --prefix=/opt/php/ --with-openssl=/usr/local/ssl --with-curl --with-zlib --without-pear
RUN make install
#
RUN /opt/php/bin/php -v
