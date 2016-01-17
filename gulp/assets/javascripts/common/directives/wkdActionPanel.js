'use strict';

angular.module('WKD.Common')

.directive('wkdActionPanel', [
  function () {
    return {
      restrict: 'E',
      transclude: true,
      scope: {
        toggleTitle: '@'
      },
      templateUrl: '/templates/directives/wkd-action-panel.html'
    };
  }
]);
