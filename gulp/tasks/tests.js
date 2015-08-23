var gulp = require('gulp');
var Server = require('karma').Server;

gulp.task('test', function (done) {
  new Server({
    configFile: __dirname + '/../tests/karma.conf.js',
    singleRun: true
  }, done).start();
});

gulp.task('ci', function (done) {
  new Server({
    configFile: __dirname + '/../tests/karma.conf.js',
  }, done).start();
});
