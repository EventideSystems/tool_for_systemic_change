var publicAssets = "./public/assets";
var sourceFiles  = "./gulp/assets";

module.exports = {
  publicAssets: publicAssets,
  browserSync: {
    proxy: 'localhost:3000',
    files: ['./app/views/**']
  },
  sass: {
    src: sourceFiles + "/stylesheets/app.scss",
    dest: publicAssets + "/stylesheets",
    settings: {
      imagePath: '/assets/images' // Used by the image-url helper
    }
  },
  images: {
    src: sourceFiles + "/images/**",
    dest: publicAssets + "/images"
  },
  browserify: {
    bundleConfigs: [{
      entries: sourceFiles + '/javascripts/app.js',
      dest: publicAssets + '/javascripts',
      outputName: 'app.js',
      extensions: ['.js']
    }]
  },
  templates: {
    src: sourceFiles + '/templates/**/*.html',
    dest: publicAssets + '/javascripts',
    cacheConfig: {
      module: 'WKD',
      root: '/templates'
    }
  },
  fonts: {
    src: ['./node_modules/font-awesome/fonts/*'],
    dest: publicAssets + '/fonts'
  }
};
