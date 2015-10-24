var gulp         = require('gulp');
var browserSync  = require('browser-sync');
var sass         = require('gulp-sass');
var sourcemaps   = require('gulp-sourcemaps');
var handleErrors = require('../util/handleErrors');
var config       = require('../config').sass;
var autoprefixer = require('gulp-autoprefixer');
var cssimport    = require("gulp-cssimport");

var del = require('del');



gulp.task('sass', ['sass:compile'], function () {
  // Not sure whats going on with cssimport and dest
  gulp.src('./gulp/assets/stylesheets/*.css').pipe(gulp.dest(config.dest));
  del('./gulp/assets/stylesheets/*.css');
});


gulp.task('sass:compile', function () {
  return gulp.src(config.src)
    .pipe(sourcemaps.init())
    .pipe(sass(config.settings))
    .on('error', handleErrors)
    .pipe(cssimport())
    .on('error', handleErrors)
    .pipe(autoprefixer({ browsers: ['last 2 version'] }))
    .pipe(sourcemaps.write())
    .pipe(gulp.dest(config.dest))
    .pipe(browserSync.reload({stream:true}));
});
