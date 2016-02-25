# jekyll-app-engine: deploy your site to Google App Engine

[![Build Status](https://img.shields.io/travis/jamesramsay/jekyll-app-engine/master.svg)](https://travis-ci.org/jamesramsay/jekyll-app-engine)
[![Version](https://img.shields.io/gem/v/jekyll-app-engine.svg)](https://rubygems.org/gems/jekyll-app-engine)

`jekyll-app-engine` makes it easy to deploy your jekyll site to Google App Engine by generating handlers for your `app.yaml`.

Using Google App Engine to host your Jekyll site has the following benefits:

- HTTPS
- HTTP cache control for pages and assets
- HTTP/2 support including PUSH
- Use custom jekyll plugins not supported by Github Pages
- Google CDN

Limitations:

- 404 handling not customisable

## Usage

Add `gem jekyll-app-engine` to your Gemfile:

```
source 'https://rubygems.org'
gem 'github-pages'
gem 'jekyll-app-engine'
```

Add configs...

## Documentation

todo
