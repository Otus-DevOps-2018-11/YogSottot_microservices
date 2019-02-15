FROM ruby:2.3-alpine
RUN apk --no-cache add make=4.2.1-r2 gcc=6.4.0-r9 libc-dev=0.7.1-r0

ENV APP_HOME /app
WORKDIR $APP_HOME

COPY Gemfile* $APP_HOME/
RUN bundle install && \
  rm -rf /root/.bundle && \
  apk --no-cache del make gcc libc-dev
COPY . $APP_HOME

ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292

CMD ["puma"]
