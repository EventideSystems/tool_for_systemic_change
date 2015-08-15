'use strict';

angular.module('WKD.Common')

.directive('wkdHeader', [
  '$http',
  function ($http) {
    return {
      restrict: 'E',
      link: function (scope) {
        scope.logout = function () {
          $http.delete('/users/sign_out.json').then(function () {
            window.location = '/';
          });
        };
      },
      templateUrl: '/templates/directives/wkd-header.html'
    };
  }
]);