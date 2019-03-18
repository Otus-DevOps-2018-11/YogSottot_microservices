ARG FLUENTD_VERSION=v1.4.0-debian-1.0
FROM fluent/fluentd:"${FLUENTD_VERSION}"

# Use root account to use apt
USER root

RUN gem install \
        fluent-plugin-elasticsearch --no-rdoc --no-ri --version 3.3.1 \
    && gem install \
        fluent-plugin-grok-parser --no-rdoc --no-ri --version 2.5.0 \
    && gem sources --clear-all \
    && apt-get purge -y --auto-remove \
                  -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/* \
           /home/fluent/.gem/ruby/2.3.0/cache/*.gem

COPY fluent.conf /fluentd/etc/
USER fluent
