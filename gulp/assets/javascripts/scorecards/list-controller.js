'use strict';


angular.module('WKD.Scorecards')

.controller('WKD.Scorecards.ListController', [
  'Restangular',
  function (Restangular) {
    var vm = this;
    var baseRef = Restangular.all('scorecards');

    baseRef.getList().then(function (resp) {
      vm.scorecards = resp;
    });

  }
]);
