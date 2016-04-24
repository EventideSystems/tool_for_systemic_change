# Wicked Labs

## Preparing for development

The Wicked Labs development environment is contained within a virtual machine. We currently only support development using OS X as a host operating system, and `brew` is required for package management.

If you don't have `brew` installed please visit http://brew.sh/ first and follow the installation instructions.

### VirtualBox

Probably the easiest way to install VirtualBox is to install the package available from Oracle. Visit https://www.virtualbox.org/ for details.

Alternatively, if using OS X, you can attempt to install using Brew's 'Cask' extension:

```
brew update
brew install caskroom/cask/brew-cask
brew cask install virtualbox
```

### Ansible and Vagrant

Both Ansbile and Vagrant are available in the standard `brew` package library:

```
brew update
brew install ansible
brew install vagrant
```

NB We are using Ansible v. 1.8.4, as it is the last version known to work with
the provisioning scripts as they are now - and later versions of Ansible
introduce bugs.

If you have issues with the version of Ansible installed by `brew`, you can
install the 1.8.x version and switch to it

```
brew install homebrew/versions/ansible18
brew info ansible
brew switch ansble [version returned from info]
```

If you have issues installing multiple versions of Ansible, you may have to
unlink the existing installed version first, and then install Ansble 1.8:

```
brew unlink ansible
brew install homebrew/versions/ansible18
```

### Database setup

You will need to ensure you have a valid `database.yml` file available. Copy the `database.vagrant.yml` template and modify as necessary (you probably won't have to change it at all).

```
cp config/database.vagrant.yml config/database.yml
```

### Provisioning the virtual machine

Once you have VirtualBox, Ansible and Vagrant installed, visit the root folder of the project and execute the following:

```
cd deploy/development/
vagrant up
```

Initial provisioning will take some time. If the process fails (e.g. network timeouts) you can restart the provisioning with `vagrant provision`.

Once the environment is up and running you can shell in using the `vagrant ssh` command. The source tree for the application can be found in the `/wicked_software` directory. You may want to run `bundle exec rake db:seed` to build the default data set for the database.

The application should be up and running at 'http://http://192.168.20.50/'.

### Managing the virtual machine

Normally the `wicked_software` application will be running, but if you need to start or stop the application from within the VM, shell in via SSH issue the appropriate command:

```
sudo start wicked_software
```
or
```
sudo stop wicked_software
```

To restart the application during development, execute the following:

```
cd /wicked_software_
touch tmp/restart.txt
```

The application uses PostgreSQL, running under its own `postgres` account. If you need to access the database shell directly, from within the VM, you will need to assume the `postgres` role:

```
sudo su postgres
psql wicked_software_development
```

You will need to be familiar with `psql` commands. Refer to the Postgres PSQL manual at http://www.postgresql.org/docs/current/static/app-psql.html for more information, though the following commands are possibly the most useful:

```
\l                  => list databases / schemas
\d                  => list database relations / tables / etc
\q                  => quit the psql shell
\c [database name]  => connect to a different database schema
```

Naturally you can execute SQL commands directly in the `psql` shell.

Managing the state of the VM (from your host environment) is via `vagrant` commands, e.g. `vagrant suspend` to pause the environment, `vagrant up` to resume it.

Refer to the Vagrant site for more details: https://www.vagrantup.com/

## Frontend setup

This setup is based off of [this repo](https://github.com/vigetlabs/gulp-rails-pipeline).

As of now, compiled JS/CSS ARE commited to source control. This will make it easier to manage deploys. However if more people start working on the frontend at the same time, these will need to come out and be build during the deploy process.

This means you will not need to do anything fancy to get the frontend working, when you checkout and start your server you should be good to go.

If you want to do frontend work, you will need to setup gulp. I'd recommend installing gulp globally with `npm install -g gulp`

You will then install all frontend dependencies with `npm install` from the root directory. This will create a `node_modules` folder. Node modules is ignored from git as the dependency structure is pretty recursive which gets big really really fast.

NOTE To successfully run `npm install` on OS X (using a `brew` managed nodejs), I found the following steps were required:

```
brew update
brew install node
npm update npm -g
npm install bower
npm uninstall --save-dev gulp-sass
npm install --save-dev gulp-sass
```


After all the dependencies are installed, simply run `gulp` and it will build all the assets in `gulp/assets/` into the public folder. The manifest files inside `app/assets` are only responsible for loading these generated files from the public folder. Sprokets can still be used to require frontend gem libraries, like jquery_ujs.

Why this over the asset pipeline?

There are many benefits but the main one is giving us the full ecosystem of modern frontend packages. The asset pipeline has not been able to keep up wih all the tools now required for building heavy javascript apps, eg:

* BrowserSync
* Linting
* Browserify
* Autoprefixer

And many other cool things that make life easier.

While there are gems that try and make these things more confortable for a rails dev, they don't offer any real value over the real thing.

### Front-end commands

To recap from above, the following commands

```
gulp             # rebuild all assets and watch for changes
gulp templates   # rebuild templates
gulp browserify  # rebuild javascript assets
```

## Styleguides

Refer to the [Rails Style Guide](https://github.com/bbatsov/rails-style-guide) for details on our preferred Ruby / Rails coding style.

NB: We use Rubocop to enforce consistent styling. Please ensure you run Rubocop in Rails mode to check for violations:

```
bundle exec rubocop -R
```
or

```
bundle exec rubocop -Ra # autofix errors
```

## Deploying

Each environment (production, development, staging) has its own provisioning and deployment scripts under the `deploy` folder. Each script makes use of Ansbile for the provisioning cycle.

### Deploying to Staging

To to deploy the current `master` branch from origin, execute the following:

```
cd deploy/staging
sh ./deploy.sh
```

This will go through the process of ensuring everything on the server is up to date, that the code is deployed and that the `current` folder on the server is swapped to point ot the new relase. A copy of last known release prior (plus recent releases) can be found in the `/wicked_software/releases` folder on the server. These can be used to rollback (currently a manual process) in the case of a failed build.

The complete deployment cycle isn't fully automated at present. To finalise the deployment process the following manual steps are required:

```
ssh root@wickedlab-staging.eventidesystems.com
service wicked_software-delayed_job restart
```

The reason for executing this by hand is the Ansible
