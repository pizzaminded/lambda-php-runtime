FROM amazonlinux:2018.03

# Update packages and install needed compilation dependencies
RUN yum update -y
RUN yum clean all
RUN yum install openssl-devel glibc zlib tar gzip cmake texinfo makeinfo help2man autoconf gcc gcc-c++ libcurl-devel libxml2-devel re2c sqlite-devel -y

ENV BUILD_DIR="/tmp/build"

ENV PHP_VERSION="7.4.0"
ENV BISON_VERSION="3.4"
#ENV OPENSSL_VERSION="1.0.1k"
#ENV CMAKE_VERSION="3.17.2"

#start in root
WORKDIR ${BUILD_DIR}


##
## Build OpenSSL from sources
##
#RUN curl -sL http://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz | tar -xvz
#WORKDIR ${BUILD_DIR}/openssl-${OPENSSL_VERSION}
#RUN ./config && make && make install
#
#
#ENV OPENSSL_ROOT_DIR=${BUILD_DIR}/openssl-${OPENSSL_VERSION}
#ENV OPENSSL_INCLUDE_DIR=${BUILD_DIR}/openssl-${OPENSSL_VERSION}/include
#ENV OPENSSL_LIBRARIES=${BUILD_DIR}/openssl-${OPENSSL_VERSION}/lib
#ENV OPENSSL_LIBS="${BUILD_DIR}/openssl-${OPENSSL_VERSION}/lib"
#ENV OPENSSL_CFLAGS="-I/${OPENSSL_INCLUDE_DIR}"


#Back to build root
WORKDIR ${BUILD_DIR}

##
## Build cmake from sources
##
#RUN curl -sL https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz | tar -xvz
#WORKDIR ${BUILD_DIR}/cmake-${CMAKE_VERSION}
#RUN ./bootstrap && make && make install

#Back to build root
WORKDIR ${BUILD_DIR}

#
# bison 3.0.0 or later is required to generate PHP parsers
# There is only 2.7 available in yum, so we need to install a fresh one manually
#
RUN curl -sL http://ftp.gnu.org/gnu/bison/bison-3.4.tar.gz | tar -xvz
WORKDIR ${BUILD_DIR}/bison-3.4
#RUN echo ${BUILD_DIR}/bison-3.4
RUN ./configure && make && make install
RUN ln -s /usr/local/bin/bison /usr/bin/bison

#
# Check that bison is installed correctly
#
RUN bison --help

#Back to build root
WORKDIR ${BUILD_DIR}


# Download the PHP 7.4.0 source
RUN curl -sL https://github.com/php/php-src/archive/php-7.4.6.tar.gz | tar -xvz
WORKDIR ${BUILD_DIR}/php-src-php-7.4.6
RUN ./buildconf --force
RUN ./configure --prefix=/opt/php/ \
    --with-openssl \
    --without-curl \
    --with-zlib \
    --without-pear

RUN make -j $(nproc) && make install
#
RUN /opt/php/bin/php -v
