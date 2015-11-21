'use strict';

angular.module('WKD.Common')

.factory('WKD.Common.TutorialService', [
  '$uibModal',
  function ($uibModal) {
    var factory = {};

    factory.play = function (title, url) {
      $uibModal.open({
        controller: ['$sce', function ($sce) {
          this.title = title;
          this.url = $sce.trustAsResourceUrl(url);
        }],
        controllerAs: 'vm',
        templateUrl: '/templates/common/video-embed.html'
      });
    };

    return factory;
  }
]);
