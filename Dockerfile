ARG DISTRIBUTION=debian
ARG DISTRIBUTION_RELEASE=buster
ARG ARCHITECTURE=amd64

FROM $ARCHITECTURE/$DISTRIBUTION:$DISTRIBUTION_RELEASE

# Arguments
ARG PASSENGER_VERSION
ARG DISTRIBUTION
ARG DISTRIBUTION_RELEASE
ARG ARCHITECTURE

# Label and default environment variables
LABEL Description="Passenger build environment" Vendor="Omniasoft"
ENV DEBIAN_FRONTEND=noninteractive

# Set our work directory
WORKDIR /build

# Change the sources list to add src for all repos
RUN sed -i -n 'p; s/^deb /deb-src /p' /etc/apt/sources.list

# Install base packages
RUN    apt-get update \
    && apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        git-buildpackage \
        ruby \
        rake \
        libcurl4-openssl-dev \
        ruby-dev \
        make \
        git \
        moreutils \
    && apt-get build-dep -y --no-install-recommends \
        nginx \
        apache2

# Clone Nginx and Passenger
RUN    gbp clone --debian-branch=$DISTRIBUTION_RELEASE https://salsa.debian.org/nginx-team/nginx.git \
    && git clone --branch release-$PASSENGER_VERSION --recurse-submodules --depth 1 https://github.com/phusion/passenger.git

# Copy patch files
ADD libnginx-mod-http-passenger.patch /build
ADD passenger.patch /build

# Build and package libnginx-mod-http-passenger
WORKDIR /build/nginx
RUN    git apply ../libnginx-mod-http-passenger.patch
RUN    gbp buildpackage --git-no-pristine-tar --git-export=WC --git-export-dir=../output --git-ignore-new || true

# Build passenger
WORKDIR /build/passenger
RUN    git apply ../passenger.patch -vvv
RUN    rake fakeroot

# Package passenger
COPY DEBIAN /build/passenger/pkg/fakeroot/DEBIAN
RUN    cd /build/passenger/pkg \
    && envsubst < "fakeroot/DEBIAN/control" | sponge "fakeroot/DEBIAN/control" \
    && dpkg-deb -b fakeroot passenger_$PASSENGER_VERSION_$ARCHITECTURE.deb

# Collect our artifacts
WORKDIR /artifacts
RUN    mv /build/passenger/pkg/*.deb . \
    && mv /build/output/libnginx-mod-http-passenger*.deb .

# Entrypoint
CMD ["bash"]
