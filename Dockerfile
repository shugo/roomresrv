FROM ruby:2.5.1-alpine  
RUN apk add --no-cache libxslt-dev libstdc++ && \
    apk add --no-cache tzdata mariadb-client-libs nodejs && \
    apk add --no-cache ca-certificates  && \
    apk add --no-cache postgresql-client

RUN mkdir /app
WORKDIR /app
COPY Gemfile Gemfile.lock /app/
RUN apk add --no-cache --virtual build-dependencies postgresql-dev libxml2-dev git build-base linux-headers && bundle install && apk del build-dependencies
COPY . /app
ENV TZ Asia/Tokyo
RUN bundle exec rake assets:precompile RAILS_ENV=production
EXPOSE 80 
CMD ["./run.sh"]
