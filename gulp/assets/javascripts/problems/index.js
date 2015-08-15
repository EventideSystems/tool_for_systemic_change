'use strict';


angular.module('WKD.Problems', [])

.config(['$stateProvider', function ($stateProvider) {
  $stateProvider
    .state('wkd.problems', {
      url: '/problems',
      template: '<ui-view>'
    })

    .state('wkd.problems.new', {
      url: '/new',
      template: '<h1>Nothing here yet</h1>',
      controller: 'WKD.Problems.Controller'
    })

    ;
}])

;

require('./controller.js');
