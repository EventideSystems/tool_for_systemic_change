'use strict';


angular.module('WKD.Dashboard')

.controller('WKD.Dashboard.Controller', [
  'Restangular',
  'WKD.Common.TutorialService',
  '$http',
  'orderByFilter',
  function (Restangular, tutorialService, $http, orderBy) {
    var vm = this;

    Restangular.one('dashboard').get().then(function (dashboard) {
      vm.dashboard = dashboard;
    });

    Restangular.all('scorecards').getList({ limit: 5 }).then(function (sc) {
      vm.scorecards = sc;
    });

    $http.get('/video_tutorials/dashboard').then(function (resp) {
      vm.videos = orderBy(resp.data.data, 'attributes.position');
    });

    vm.playVideo = function (video) {
      tutorialService.play(video.attributes.name, video.attributes.linkUrl);
    };
  }
]);
