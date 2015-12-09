'use strict';


angular.module('WKD.Reports', [])

.config(['$stateProvider', function ($stateProvider) {
  $stateProvider
    .state('wkd.reports', {
      url: '/reports',
      templateUrl: '/templates/reports/index.html',
      title: 'Reports'
    })

    ;
}])

;
