'use strict';


angular.module('WKD.Dashboard')

.controller('WKD.Dashboard.Controller', [
  'Restangular',
  function (Restangular) {
    var vm = this;

    Restangular.one('dashboard').get().then(function (dashboard) {
      vm.dashboard = dashboard;
    });

    Restangular.all('scorecards').getList({ limit: 5 }).then(function (sc) {
      vm.scorecards = sc;
    });
  }
]);
