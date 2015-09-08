'use strict';


angular.module('WKD.Problems')

.controller('WKD.Problems.InitiativeController', [
  'Restangular',
  'flashr',
  'currentProblem', //injected by resolve
  function (Restangular, flashr, currentProblem) {
    var vm = this;

    vm.initiatives = _.where(currentProblem.included, { type: 'initiatives' });

    /////////////////////////////////////////////////////////////////////////
  }
]);
