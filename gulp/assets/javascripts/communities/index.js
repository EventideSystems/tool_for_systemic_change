'use strict';


angular.module('WKD.Communities', [])

.config(['$stateProvider', function ($stateProvider) {
  $stateProvider
    .state('wkd.communities', {
      url: '/communities',
      template: '<ui-view>'
    })

    .state('wkd.communities.new', {
      url: '/new',
      template: 'Nothing here yet',
      controller: 'WKD.Communities.Controller'
    })

    ;
}])

;

require('./controller.js');
