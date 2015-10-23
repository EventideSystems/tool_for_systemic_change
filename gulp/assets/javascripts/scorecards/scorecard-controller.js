'use strict';


angular.module('WKD.Scorecards')

.controller('WKD.Scorecards.ScorecardController', [
  'flashr',
  'Restangular',
  '$stateParams',
  function (flashr, Restangular, $stateParams) {
    var vm = this;
    var baseRef = Restangular.one('scorecards', $stateParams.id).all('initiatives');

    baseRef.getList().then(function (initiatives) {
      vm.initiatives = initiatives;
    });

    /////////////////////////////////////////////////////////////////////////
  }
]);
