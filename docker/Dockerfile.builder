FROM alpine:3.19 AS builder

# Install minimal build dependencies
RUN apk add --no-cache \
    build-base \
    cmake \
    git \
    boost-dev \
    sqlite-dev \
    openssl-dev \
    zlib-dev \
    libharu-dev \
    pango-dev \
    fcgi-dev \
    linux-headers

# Build Wt framework
WORKDIR /tmp
RUN git clone --depth 1 --branch 4.11-release https://github.com/emweb/wt.git

WORKDIR /tmp/wt/build
RUN cmake .. \
    -DCMAKE_BUILD_TYPE=MinSizeRel \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DSHARED_LIBS=ON \
    -DMULTI_THREADED=ON \
    -DENABLE_SQLITE=ON \
    -DENABLE_POSTGRES=OFF \
    -DENABLE_MYSQL=OFF \
    -DENABLE_FIREBIRD=OFF \
    -DENABLE_MSSQLSERVER=OFF \
    -DENABLE_SSL=ON \
    -DENABLE_HARU=ON \
    -DENABLE_PANGO=ON \
    -DENABLE_OPENGL=OFF \
    -DENABLE_SAML=OFF \
    -DENABLE_QT4=OFF \
    -DENABLE_QT5=OFF \
    -DENABLE_QT6=OFF \
    -DENABLE_LIBWTDBO=ON \
    -DENABLE_LIBWTTEST=OFF \
    -DENABLE_UNWIND=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_TESTS=OFF \
    -DINSTALL_EXAMPLES=OFF \
    -DINSTALL_DOCUMENTATION=OFF \
    -DINSTALL_RESOURCES=ON \
    -DINSTALL_THEMES=ON \
    -DCONNECTOR_HTTP=ON \
    -DCONNECTOR_FCGI=ON

RUN make -j$(nproc) && make install

# Copy application files
COPY ./resources /apps/cv/resources
COPY ./src /apps/cv/src
COPY ./static /apps/cv/static
COPY ./CMakeLists.txt /apps/cv/CMakeLists.txt
COPY ./wt_config.xml /apps/cv/wt_config.xml

# Build the application
WORKDIR /apps/cv/build/release
RUN cmake -DCMAKE_BUILD_TYPE=MinSizeRel ../.. && make -j$(nproc)

# Strip the binary to reduce size significantly
RUN strip --strip-all /apps/cv/build/release/app

# Strip Wt libraries
RUN find /usr/local/lib -name "libwt*.so.*" -exec strip --strip-unneeded {} \;

# Clean up unnecessary files to reduce layer size
RUN rm -rf /tmp/wt \
    && rm -rf /apps/cv/src \
    && rm -rf /apps/cv/CMakeLists.txt \
    && rm -rf /apps/cv/build/release/CMakeFiles \
    && rm -rf /apps/cv/build/release/cmake_install.cmake \
    && rm -rf /apps/cv/build/release/Makefile \
    && rm -rf /apps/cv/build/release/_deps
