FROM alpine:3.9 as builder

ENV APP_HOME /app
WORKDIR $APP_HOME

COPY Gemfile* $APP_HOME/

ENV RUBY_VERSION 2.5.3-r1

RUN apk --no-cache add ruby="$RUBY_VERSION" ruby-bundler=1.17.1-r0 ruby-dev="$RUBY_VERSION" ruby-json="$RUBY_VERSION" make=4.2.1-r2 gcc=8.2.0-r2 libc-dev=0.7.1-r0 && \
  bundle install && \
  rm -rf /root/.bundle && \
  apk --no-cache del make gcc libc-dev ruby-dev
COPY . $APP_HOME

ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292

CMD ["puma"]
