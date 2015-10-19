'use strict';


angular.module('WKD.Scorecards')

.controller('WKD.Scorecards.ScorecardController', [
  'flashr',
  'Restangular',
  'WKD.Common.DataModel',
  'currentCard', //injected by resolve
  function (flashr, Restangular, dataModel, currentCard) {
    var vm = this;

    vm.initiatives = _.where(currentCard.included, { type: 'initiatives' });

    /////////////////////////////////////////////////////////////////////////
  }
]);
