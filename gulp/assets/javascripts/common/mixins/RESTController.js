'use strict';

angular.module('WKD.Common')

// $scope in this case with be an instance of another controller
.controller('WKD.Common.RESTController', [
  '$scope',
  '$state',
  '$stateParams',
  function ($scope, $state, $stateParams) {
    $scope.action = $state.current.action;

    if (_.isFunction($scope._beforeAll)) {
      var promise = $scope._beforeAll($stateParams);

      if (promise && promise.then) promise.then(actionController);
      else actionController();
    } else {
      actionController();
    }

    function actionController() {
      var fn = $scope['_' + $scope.action];

      if (_.isFunction(fn)) fn($stateParams);
      else throw new Error('No method for action _' + $scope.action);
    }
  }
]);
