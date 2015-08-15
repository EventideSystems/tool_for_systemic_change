'use strict';


angular.module('WKD.Organisations', [])

.config(['$stateProvider', function ($stateProvider) {
  $stateProvider
    .state('wkd.organisations', {
      url: '/organisations',
      template: '<ui-view>'
    })

    .state('wkd.organisations.new', {
      url: '/new',
      templateUrl: '/templates/organisations/new.html',
      controller: 'WKD.Organisations.Controller',
      controllerAs: 'vm'
    })

    ;
}])

;

require('./controller.js');
