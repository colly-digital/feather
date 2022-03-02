# ================================
# Build image
# ================================
# TODO: should move to fixed image eventually
FROM swiftlang/swift:nightly-5.5-focal as build

# Install OS updates and, if needed, sqlite3
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get -q install libxml2-dev -y \
    && apt-get -q install libsqlite3-dev -y \
    && rm -rf /var/lib/apt/lists/*

# Set up a build area
WORKDIR /build

# First just resolve dependencies.
# This creates a cached layer that can be reused
# as long as your Package.swift/Package.resolved
# files do not change.
COPY ./Package.* ./
# temporarily disable
# RUN swift package resolve

# Copy entire repo into container
COPY . .

# Build everything, with optimizations and test discovery
RUN swift build --enable-test-discovery -c release

# Switch to the staging area
WORKDIR /staging

# Copy main executable to staging area
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/Run" ./

# Copy any resouces from the public directory and views directory if the directories exist
# Ensure that by default, neither the directory nor any of its contents are writable.
RUN [ -d /build/Public ] && { mv /build/Public ./Public && chmod -R a-w ./Public; } || true
RUN [ -d /build/Resources ] && { mv /build/Resources ./Resources && chmod -R a-w ./Resources; } || true

# ================================
# Run image
# ================================
# TODO: should move to fixed slim image eventually
FROM swiftlang/swift:nightly-5.5-focal

# Make sure all system packages are up to date.
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && \
    apt-get -q update && apt-get -q dist-upgrade -y \
        && apt-get -q install libxml2 -y \
        && apt-get -q install libsqlite3-0 -y \
        && rm -r /var/lib/apt/lists/*

# Create a vapor user and group with /app as its home directory
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app vapor

# Switch to the new home directory
WORKDIR /app

# Copy built executable and any staged resources from builder
COPY --from=build --chown=vapor:vapor /staging /app

# Ensure all further commands run as the vapor user
USER vapor:vapor

ENV LOG_LEVEL=
ENV DATABASE_HOST=
ENV DATABASE_PORT= 
ENV DATABASE_NAME=
ENV DATABASE_USERNAME=
ENV DATABASE_PASSWORD=
ENV DATABASE_CERTIFICATE_PATH=

# the base path (absolute) of the working directory
ENV FEATHER_WORK_DIR=

# Optional Feather related env variables

# the hostname (domain) of your web server, default localhost
ENV FEATHER_HOSTNAME=
# the port to listen on, default 8080
ENV FEATHER_PORT=
# use HTTPS, default false (needs cert & key setup on the Vapor app)
ENV FEATHER_HTTPS=
# maximum body size for file uploads
ENV FEATHER_MAX_BODY_SIZE=
# disable file middleware, default false (if disabled you can serve files with nginx)
ENV FEATHER_DISABLE_FILE_MIDDLEWARE=
# disable the session auth middleware for api endpoints (recommended for production)
ENV FEATHER_DISABLE_API_SESSION_MIDDLEWARE=

# Let Docker bind to port 8080
EXPOSE 8080

# Start the Vapor service when the image is run, default to listening on 8080 in production environment
ENTRYPOINT ["./Run"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
