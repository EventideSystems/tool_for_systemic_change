'use strict';

angular.module('WKD.Common')

.directive('wkdHeader', [
  '$http',
  'WKD.Common.CurrentUser',
  'Restangular',
  function ($http, currentUser, Restangular) {
    return {
      restrict: 'E',
      link: function (scope) {
        scope.logout = function () {
          $http.delete('/users/sign_out.json').then(function () {
            window.location = '/';
          });
        };

        if (currentUser.hasRole('staff')) {
          $http.get('/current_client').then(function (resp) {
            scope.currentContext = resp.data.data.id;
            scope.newContext = scope.currentContext;
            currentUser.setClientName(resp.data.data.attributes.name);
          });

          Restangular.all('clients').getList().then(function (clients) {
            scope.clients = clients;
          });

          scope.changeContext = changeContext;
        }

        function changeContext() {
          if (scope.currentContext !== scope.newContext) {
            $http.put('/current_client', _.find(scope.clients, {
              id: scope.newContext
            })).then(function () {
              window.location.href = '/';
            });
          }
        }
      },
      templateUrl: '/templates/directives/wkd-header.html'
    };
  }
]);
