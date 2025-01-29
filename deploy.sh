#!/bin/bash
set -e

cd "$(dirname "$0")"
# bundle update
# bundle exec rake
sed -i -s 's|Gemfile.lock||g' .gitignore
cp /code/home/assets/sixnines/config.yml .
git add config.yml
git add Gemfile.lock
git add .gitignore
git commit -m 'config.yml for heroku'
trap 'git reset HEAD~1 && rm config.yml && git checkout -- .gitignore' EXIT
git push heroku master -f
