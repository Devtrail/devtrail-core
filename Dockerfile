#==> Start of layer: core
# Package pdftk is not present at alpine v3.9
FROM ruby:2.7.1-alpine3.8 AS core

WORKDIR /agendesimples-core

RUN apk update \
# Build-layer (will be removed after build) \
&& apk add --no-cache --virtual build-layer \
  git \
  build-base \
  linux-headers \
  postgresql-dev \
  libxml2-dev \
  libxslt-dev \
# Runtime-layer \
&& apk add --no-cache --virtual runtime-layer \
  curl \
  libpq \
  libxml2 \
  libxslt \
  tzdata \
  pdftk \
  poppler-utils \
  openjdk8-jre \
  nss \
  msttcorefonts-installer \
  imagemagick \
# Node-layer \
&& apk add \
  --no-cache --virtual node-layer \
  --repository http://dl-cdn.alpinelinux.org/alpine/v3.10/main/ \
  nodejs
#==> End of layer: core

#==> Start of layer: gems
FROM core AS gems

COPY Gemfile Gemfile.lock /agendesimples-core/

# Run bundle install
RUN gem install bundler -v 2.2.15 \
&& bundle config build.nokogiri \
  --use-system-libraries \
  --with-xml2-lib=/usr/include/libxml2 \
  --with-xml2-include=/usr/include/libxml2 \
&& bundle config gems.contribsys.com 0f48e5f5:169cf62f \
&& bundle install --deployment --no-cache --jobs $(nproc) \
&& update-ms-fonts \
&& fc-cache -f \
# Clean-up
&& find vendor/bundle/ruby/*/extensions \
  -type f -name "mkmf.log" -o -name "gem_make.out" | xargs rm -f \
&& find vendor/bundle/ruby/*/gems -maxdepth 2 \
  \( -type d -name "spec" -o -name "test" -o -name "docs" \) -o \
  \( -name "*LICENSE*" -o -name "README*" -o -name "CHANGELOG*" \
  -o -name "*.md" -o -name "*.txt" -o -name ".gitignore" -o -name ".travis.yml" \
  -o -name ".rubocop.yml" -o -name ".yardopts" -o -name ".rspec" \
  -o -name "appveyor.yml" -o -name "COPYING" -o -name "SECURITY" \
  -o -name "HISTORY" -o -name "CODE_OF_CONDUCT" -o -name "CONTRIBUTING" \
  \) | xargs rm -rf
