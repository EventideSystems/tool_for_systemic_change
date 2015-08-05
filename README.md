# wicked_software

## Frontend setup

This setup is based off of [this repo](https://github.com/vigetlabs/gulp-rails-pipeline).

As of now, compiled JS/CSS ARE commited to source control. This will make it easier to manage deploys. However if more people start working on the frontend at the same time, these will need to come out and be build during the deploy process.

This means you will not need to do anything fancy to get the frontend working, when you checkout and start your server you should be good to go.

If you want to do frontend work, you will need to setup gulp. I'd recommend installing gulp globally with `npm install -g gulp`

You will then install all frontend dependencies with `npm install` from the root directory. This will create a `node_modules` folder. Node modules is ignored form git as the dependency structure is pretty recursive which gets big really really fast.

After all the dependencies are installed, simply run `gulp` and it will build all the assets in `gulp/assets/` into the public folder. The manifest files inside `app/assets` are only responsible for loading these generated files from the public folder. Sprokets can still be used to require frontend gem libraries, like jquery_ujs. 

Why this over the asset pipeline? 

There are many benefits but the main one is giving us the full ecosystem of modern frontend packages. The asset pipeline has not been able to keep up wih all the tools now required for building heavy javascript apps, eg:

* BrowserSync
* Linting
* Browserify
* Autoprefixer

And many other cool things that make life easier.

While there are gems that try and make these things more confortable for a rails dev, they don't offer any real value over the real thing.