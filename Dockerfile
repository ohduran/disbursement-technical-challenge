FROM ruby:latest

RUN mkdir -p /backend

WORKDIR /backend

COPY ./backend/Gemfile Gemfile
COPY ./backend/Gemfile.lock Gemfile.lock

RUN bundle install

COPY ./backend ./backend
