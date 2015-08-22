'use strict';


angular.module('WKD.Problems')

.controller('WKD.Problems.Controller', [
  'WKD.Common.SidebarService',
  '$modal',
  function (sidebarService, $modal) {
    var vm = this;

    vm.openModal = function (resource) {
      $modal.open({
        templateUrl: '/templates/problems/' + resource + '-modal.html',
        controller: 'WKD.Communities.Controller',
        size: 'lg'
      });
    };
  }
]);
