<img src="http://www.sixnines.io/images/logo.png" width="64px" height="64px"/>

[![DevOps By Rultor.com](http://www.rultor.com/b/yegor256/sixnines)](http://www.rultor.com/p/yegor256/sixnines)
[![We recommend RubyMine](http://img.teamed.io/rubymine-recommend.svg)](https://www.jetbrains.com/ruby/)

[![Availability at SixNines](http://www.sixnines.io/b/3b05e836)](http://www.sixnines.io/h/3b05e836)

[![Build Status](https://travis-ci.org/yegor256/sixnines.svg)](https://travis-ci.org/yegor256/sixnines)
[![PDD status](http://www.0pdd.com/svg?name=yegor256/sixnines)](http://www.0pdd.com/p?name=yegor256/sixnines)
[![Dependency Status](https://gemnasium.com/yegor256/sixnines.svg)](https://gemnasium.com/yegor256/sixnines)
[![Code Climate](http://img.shields.io/codeclimate/github/yegor256/sixnines.svg)](https://codeclimate.com/github/yegor256/sixnines)
[![Test Coverage](https://img.shields.io/codecov/c/github/yegor256/sixnines.svg)](https://codecov.io/github/yegor256/sixnines?branch=master)

## What does it do?

[sixnines.io](http://www.sixnines.io) is a hosted service to validate
and prove availability of your web service and sites. Read this blog
post for more details:
[SixNines.io, Your Website Availability Monitor](http://www.yegor256.com/2017/04/25/sixnines.html).

The badge is available as:

```
http://www.sixnines.io/b/3b05e836?style=flat&format=png
```

Here, the `style` parameter can be either `round` or `flat`.
The `format` parameter can be either `svg` (106x20) or `png` (424x80).

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

The `sn-counts` table contains the total pings atomic counter:

```
fields:
  id/S: identifier for the counter. it's 'ping-count' for the ping counter
  count/N: updated value of the counter
  description/S: spoken language description of the counter
```

## How to contribute?

Just submit a pull request. Make sure `rake` passes.

Prerequisites:

  * [Ruby](https://www.ruby-lang.org/en/) 2.0+
  * [Bundler](http://bundler.io/)
  * [Maven](https://maven.apache.org/) 3.2+

To run it locally:

```
$ rake run
```

Then, point your browser to `http://localhost:9292` and enjoy.

## License

(The MIT License)

Copyright (c) 2017 Yegor Bugayenko

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the 'Software'), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
