<img alt="logo" src="https://www.sixnines.io/images/logo.png" width="64px" height="64px"/>

[![DevOps By Rultor.com](http://www.rultor.com/b/yegor256/sixnines)](http://www.rultor.com/p/yegor256/sixnines)
[![We recommend RubyMine](https://www.elegantobjects.org/rubymine.svg)](https://www.jetbrains.com/ruby/)

[![rake](https://github.com/yegor256/sixnines/actions/workflows/rake.yml/badge.svg)](https://github.com/yegor256/sixnines/actions/workflows/rake.yml)
[![PDD status](http://www.0pdd.com/svg?name=yegor256/sixnines)](http://www.0pdd.com/p?name=yegor256/sixnines)
[![Maintainability](https://api.codeclimate.com/v1/badges/c3b56d829753998ee405/maintainability)](https://codeclimate.com/github/yegor256/sixnines/maintainability)
[![Hits-of-Code](https://hitsofcode.com/github/yegor256/sixnines)](https://hitsofcode.com/view/github/yegor256/sixnines)
[![codecov](https://codecov.io/gh/yegor256/sixnines/branch/master/graph/badge.svg)](https://codecov.io/gh/yegor256/sixnines)

[![Availability at SixNines](https://www.sixnines.io/b/9ccc)](https://www.sixnines.io/h/9ccc)

[SixNines](https://www.sixnines.io) is a hosted service to validate
and prove availability of your web service and sites.

Read this blog post for more details:
[_SixNines.io, Your Website Availability Monitor_](http://www.yegor256.com/2017/04/25/sixnines.html).

The badge is available as:

```
https://www.sixnines.io/b/5fa8?style=flat&format=png
```

Here, the `style` parameter can be either `round` or `flat`.
The `format` parameter can be either `svg` (106x20) or `png` (424x80).

This is how you put it in your `README` (in Markdown):

```
[![Availability at SixNines](https://www.sixnines.io/b/5fa8)](https://www.sixnines.io/h/5fa8)
```

The badge you see above works exactly like that.

## DynamoDB Schema

The `sn-endpoints` table contains all registered end-points:

```
fields:
  login/H: GitHub login of the owner
  uri/R: URI of the endpoint, e.g. "http://www.google.com/?q=hello"
  id: Unique ID of the endpoint
  active: "yes" if it's alive, "no" otherwise
  created: Epoch time number of when it was added
  hostname: Host name of the URI, e.g. "google.com"
  pings: Total amount of ping's we've done so far
  failures: Total amount of failed attempts
  state: Either "up" or "down"
  updated: Epoch time of the most recent update of this record
  flipped: Epoch time of recent state change
  expires: Epoch time when it has to be pinged again
  log: Detailed log of the most recent failure
  favicon: URI of the favicon
sn-endpoints/unique: (index)
  id/H
sn-endpoints/hostnames: (index)
  active/H
  hostname/R
sn-endpoints/flips: (index)
  active/H
  flipped/R
sn-endpoints/expires: (index)
  active/H
  expires/R
```

The `sn-pings` table contains all recent pings:

```
fields:
  uri/H: URI of the endpoint we pinged
  time/R: Epoch time of ping
  local: IP address where we were pinging from
  remote: IP address of the endpoint we reached
  msec: How many milliseconds it took
  code: HTTP response code (2xx means success)
  delete_on: TTL attribute for DynamoDB (when to delete this item)
```

## How to contribute?

First, install
[Java 8+](https://java.com/en/download/),
[Maven 3.2+](https://maven.apache.org/),
[Ruby 2.3+](https://www.ruby-lang.org/en/documentation/installation/),
[Rubygems](https://rubygems.org/pages/download),
and
[Bundler](https://bundler.io/).
Then:

```bash
$ bundle update
$ bundle exec rake --quiet
```

The build has to be clean. If it's not, [submit an issue](https://github.com/zold-io/out/issues).

Then, make your changes, make sure the build is still clean,
and [submit a pull request](https://www.yegor256.com/2014/04/15/github-guidelines.html).

In order to run a single test:

```bash
$ bundle exec rake run
```

Then, in another terminal:

```bash
$ bundle exec ruby test/test_base.rb -n test_lists_flips
```

Then, if you want to test the UI, open `http://localhost:9292` in your browser,
and login, if necessary, by adding `?glogin=tester` to the URL.
