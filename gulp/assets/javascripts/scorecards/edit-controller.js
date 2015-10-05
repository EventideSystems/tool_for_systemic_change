'use strict';


angular.module('WKD.Scorecards')

.controller('WKD.Scorecards.EditController', [
  'Restangular',
  'flashr',
  '$stateParams',
  '$state',
  'currentCard', //injected by resolve
  function (Restangular, flashr, $stateParams, $state, currentCard) {
    var vm = this;

    Restangular.all('communities').getList().then(function (resp) {
      vm.communities = resp;
    });

    Restangular.all('wicked_problems').getList().then(function (resp) {
      vm.problems = resp;
    });

    vm.scorecard = currentCard;

    vm.update = function () {
      return vm.scorecard.put().then(function () {
        flashr.now.success('Scorecard updated!');
      });
    };

    vm.destroy = function () {
      if (!window.confirm('Are you sure you want to delete this?')) return;

      vm.scorecard.remove().then(function () {
        flashr.later.success('Scorecard deleted');
        $state.go('wkd.scorecards');
      });
    };

    /////////////////////////////////////////////////////////////////////////


  }
]);
