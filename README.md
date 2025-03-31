# didww-v3-rails-sample

[![Tests](https://github.com/didww/didww-v3-rails-sample/actions/workflows/tests.yml/badge.svg?branch=master)](https://github.com/didww/didww-v3-rails-sample/actions/workflows/tests.yml)

This is a simple Rails app demonstrating [didww-v3](https://github.com/didww/didww-v3-ruby) gem integration.

For details on obtaining your DIDWW API key please visit https://doc.didww.com/api#introduction-api-keys

See it running live at https://didww-v3-demo.herokuapp.com or [Fork it](https://github.com/didww/didww-v3-rails-sample/fork)

## Running Locally

Make sure you have [Ruby](https://www.ruby-lang.org), [Bundler](http://bundler.io) and the [Heroku Toolbelt](https://toolbelt.heroku.com/) installed.

```sh
git clone git@github.com:didww/didww-v3-rails-sample.git # or clone your own fork
cd didww-v3-rails-sample
rvm use 3.3.7
bundle install
yarn install
heroku local
```

Your app should now be running on [localhost:5000](http://localhost:5000/).

Also for build assets through webpack you can use `NODE_OPTIONS=--openssl-legacy-provider` ENV variable while running project or execute **bin/webpack**

## Deploying to Heroku

```
heroku create
git push heroku master
heroku open
```

Alternatively, you can deploy your own copy of the app using the web-based flow:

[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

## Documentation

For more information about using Ruby on Heroku, see these Dev Center articles:

- [Ruby on Heroku](https://devcenter.heroku.com/categories/ruby)
- [Getting Started with Ruby on Heroku](https://devcenter.heroku.com/articles/getting-started-with-ruby)
- [Heroku Ruby Support](https://devcenter.heroku.com/articles/ruby-support)
