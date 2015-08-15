var gulp         = require('gulp');
var browserSync  = require('browser-sync');
var templates    = require('gulp-angular-templatecache');
var handleErrors = require('../util/handleErrors');
var config       = require('../config').templates;

gulp.task('templates', function () {
  return gulp.src(config.src)
    .pipe(templates(config.cacheConfig))
    .on('error', handleErrors)
    .pipe(gulp.dest(config.dest))
    .pipe(browserSync.reload({stream:true}));
});
