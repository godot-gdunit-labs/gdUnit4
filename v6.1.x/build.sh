bundle clean --force
bundle install
# bundle exec just-the-docs rake search:init
bundle exec jekyll build

# cp -rf ./_site/* ../gh-pages/
