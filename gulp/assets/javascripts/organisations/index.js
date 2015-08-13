'use strict';


angular.module('WKD.Organisations', [])

.config(['$stateProvider', function ($stateProvider) {
  $stateProvider
    .state('organisations', {
      url: '/organisations',
      template: '<ui-view>'
    })

    .state('organisations.new', {
      url: '/new',
      templateUrl: '/templates/organisations/new.html',
      controller: 'WKD.Organisations.Controller'
    })

    ;
}])

;

require('./controller.js');
