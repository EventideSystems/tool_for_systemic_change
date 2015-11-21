'use strict';


angular.module('WKD.Tutorials', [])

.config(['$stateProvider', function ($stateProvider) {
  $stateProvider
    .state('wkd.tutorials', {
      url: '/tutorials',
      templateUrl: '/templates/tutorials/index.html',
    })

    ;
}])

;
