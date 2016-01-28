'use strict';


angular.module('WKD.Scorecards')

.controller('WKD.Scorecards.EmbedController', [
  'flashr',
  'Restangular',
  '$stateParams',
  '$timeout',
  function (flashr, Restangular, $stateParams, $timeout) {
    var vm = this;

    Restangular.one('scorecards', $stateParams.guid).all('initiatives')
      .getList().then(function (initiatives) {
        vm.initiatives = initiatives;

        $timeout(function () {
          // YEAH i know.. i know...
          $('.scorecard-embed').animate({ height:
            $('.scorecard-matrix .wrapper').outerHeight() +
            $('.scorecard-matrix-controls').outerHeight() +
            $('.scorecard-embed footer').outerHeight() + 130
          });
        }, 500);

      });

    Restangular.one('scorecards', $stateParams.guid).get()
      .then(function (scorecard) { vm.scorecard = scorecard; });
  }
]);
