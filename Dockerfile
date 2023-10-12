FROM ruby:2.6 AS githubpagebase
RUN apt-get update && apt-get install -y     

ENV CHOKIDAR_USEPOLLING 1
EXPOSE 4000

RUN gem install bundler -v 2.3.26
COPY Gemfile ./ 
RUN bundle install

RUN mkdir -p /app 
WORKDIR /app

#CMD "/bin/bash"

FROM githubpagebase as githubpagedagopecom
COPY Gemfile ./
#COPY Gemfile.lock ./
RUN bundle install
CMD "/bin/bash"

# Build image:
# docker build . -t githubpagedagopecom:v2.0