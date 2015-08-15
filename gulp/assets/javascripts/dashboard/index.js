'use strict';


angular.module('WKD.Dashboard', [])

.config(['$stateProvider', function ($stateProvider) {
  $stateProvider
    .state('wkd.dashboard', {
      url: '/',
      templateUrl: '/templates/dashboard/index.html',
      controller: 'WKD.Dashboard.Controller'
    })

    ;
}])

;

require('./controller.js');
