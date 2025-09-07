#!/usr/bin/env bash

# SPDX-FileCopyrightText: Copyright (c) 2017-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e -o pipefail

cd "$(dirname "$0")"
bundle exec rake
sed -i -s 's|Gemfile.lock||g' .gitignore
cp /code/home/assets/sixnines/config.yml .
git add config.yml
git add Gemfile.lock
git add .gitignore
git commit --no-verify -m 'config.yml for heroku'
trap 'git reset HEAD~1 && rm config.yml && git checkout -- .gitignore' EXIT
git push heroku master -f
