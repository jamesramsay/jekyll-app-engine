# Jekyll App Engine: easy deployments to Google App Engine

[![Build Status](https://img.shields.io/travis/jamesramsay/jekyll-app-engine/master.svg)](https://travis-ci.org/jamesramsay/jekyll-app-engine)
[![Version](https://img.shields.io/gem/v/jekyll-app-engine.svg)](https://rubygems.org/gems/jekyll-app-engine)
[![Coverage Status](https://img.shields.io/codecov/c/github/jamesramsay/jekyll-app-engine/master.svg)](https://codecov.io/github/jamesramsay/jekyll-app-engine)

Jekyll App Engine (`jekyll-app-engine`) makes it easy to deploy your [Jekyll](http://jekyll.com) static site to [Google App Engine](https://appengine.google.com) by generating your `app.yaml` handlers.

Hosting your static site on Google App Engine gives you greater flexibility than using Github Pages and may potentially be cheaper and more configurable than Amazon AWS.
Using Google App Engine allows:

- fine grained HTTP cache control for pages and assets,
- HTTP/2 support including server push `Link: "</assets/style.css>; rel=preload; as=style,"`, and
- custom jekyll plugins not permitted by Github Pages, such as [`jekyll-assets`](http://github.com/jekyll/jekyll-assets)

Using Google App Engine has some challenges:

- Customising handling of 404 errors can only be done by running an application instance, which may be costly.

## Get Started

These instructions assume you already have a [Google App Engine account](https://console.cloud.google.com/).

### 1. Install jekyll-app-engine

Add `gem jekyll-app-engine` to your `Gemfile`.

```
source 'https://rubygems.org'
gem 'github-pages'
gem 'jekyll-app-engine'
```

Add to your `config.yml`.

```yaml
gems:
  - jekyll-app-engine
```

### 2. Basic configuration

Specify a basic configuration in the file `_app.yaml` or using the `app_engine` option configurations to your Jekyll `_config.yml`.

```yaml
app_engine:
  # Insert your configuration here or within _app.yaml
  # You need to specify a runtime for App Engine
  runtime: go
  api_version: go1
  default_expiration: 300s
```

### 3. Create an empty 'app'

App Engine expects all apps to have some sort of application.
Create a file called `init.go`.

```go
// Included to enable deployment to Google App Engine
package hello

import (
)

func init() {
}
```

You can put this anywhere, for example in a folder `_app/init.go` to keep your root tidy.

### 4. Test and Deploy

Build your jekyll site, and you should notice the file `app.yaml` in the output directory.
Before deploying you will need to move this file to the projects root directory, where your `config.yml` file is located.

Automatic deployment using Travis: https://docs.travis-ci.com/user/deployment/google-app-engine

Manual deployment using the Google App Engine tools: todo

## Documentation

### Basic Configuration

jekyll-app-engine can be configured by creating a file `_app.yaml` in the source directory or by providing the configuration in the Jekyll config `_config.yml`.
The `handlers` option allows you to specify custom http headers and other feature supported by Google App Engine by Jekyll content type. The supported content types are:

- `posts`
- `pages`
- `collections`
- `static`

If you provide an Array or a `url` option, the configuration for the content type will be inserted directly as a handler, instead of generating a handler per item within the content type.

### Document Specific Overrides

Each document can specify overrides within the document's YAML frontmatter.
