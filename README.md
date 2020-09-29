# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

To deploy master branch on to the production system:

```
git push heroku master
```


## Development Environment

```
docker-compose build
docker-compose up -d
docker-compose run web rake db:create
docker-compose run web rake db:migrate
docker-compose run web rake db:seed
```

### Running RSpec

`docker-compose run -e "RAILS_ENV=test" web bundle exec rspec`

### Running Rails

Start up the full environment in background mode:

`docker-compose up -d`
 
Check that the `wicked_software_web_1` container is running:
 
`docker ps | grep wicked_software_web_1`

Attach to the `wicked_software_web_1` container (for debugging with `pry`): 

`docker attach wicked_software_web_1`

When you are done with the environment:

`docker-compose down`

### Accessing the shell

`docker exec -it wicked_software_web_1 bash`

### Accessing Postgres

```
docker exec -it wicked_software_db_1 bash
su - postgres
psql
```

### Building on Heroku

Have been trying a lot of things, nothing working. But something like this may work:

heroku buildpacks:clear -a wickedlab-staging
heroku buildpacks:add https://github.com/ferrisoxide/heroku-buildpack-python.git -i 1 -a wickedlab-staging
heroku buildpacks:add heroku/nodejs -i 2 -a wickedlab-staging
heroku buildpacks:add heroku/ruby -i 3 -a wickedlab-staging

git push -f wickedlab-staging staging:master 
