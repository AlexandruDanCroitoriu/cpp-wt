FROM alpine:3.19

# Install minimal runtime dependencies (removed graphicsmagick)
RUN apk add --no-cache \
    libstdc++ \
    boost-filesystem \
    boost-program_options \
    boost-thread \
    boost-system \
    sqlite-libs \
    openssl \
    zlib \
    libharu \
    pango \
    fcgi \
    busybox-extras \
    && rm -rf /var/cache/apk/*

# Create non-root user for security
RUN addgroup -g 1000 wtapp && \
    adduser -D -u 1000 -G wtapp wtapp

# Copy only necessary Wt libraries from builder
COPY --from=builder /usr/local/lib/libwt.so.* /usr/local/lib/
COPY --from=builder /usr/local/lib/libwthttp.so.* /usr/local/lib/
COPY --from=builder /usr/local/lib/libwtdbo.so.* /usr/local/lib/
COPY --from=builder /usr/local/lib/libwtdbosqlite3.so.* /usr/local/lib/

# Copy only necessary Wt resources (themes and essential CSS)
COPY --from=builder /usr/local/share/Wt/resources/themes /usr/local/share/Wt/resources/themes
COPY --from=builder /usr/local/share/Wt/resources/*.css /usr/local/share/Wt/resources/

# Copy only the built application binary and essential runtime files
COPY --from=builder /apps/cv/build/release/app /apps/cv/
COPY --from=builder /apps/cv/wt_config.xml /apps/cv/
COPY --from=builder /apps/cv/resources /apps/cv/resources
COPY --from=builder /apps/cv/static /apps/cv/static

# Set library path
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# Create necessary directories with proper permissions BEFORE switching user
# The database will be created at /apps/dbo.db (appRoot + "../dbo.db")
# appRoot() = /apps/cv/, so ../dbo.db = /apps/dbo.db
RUN mkdir -p /apps/cv/data /apps/cv/logs /apps/cv/build && \
    chown -R wtapp:wtapp /apps && \
    chmod +x /apps/cv/app && \
    chmod -R 755 /apps

# Switch to non-root user
USER wtapp

WORKDIR /apps/cv

# Expose application port
EXPOSE 9020

# Health check using netcat
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD nc -z localhost 9020 || exit 1

# Run application
CMD ["./app", \
    "--docroot", ".", \
    "-c", "wt_config.xml", \
    "--http-address", "0.0.0.0", \
    "--http-port", "9020"]
