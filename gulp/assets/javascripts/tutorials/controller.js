'use strict';


angular.module('WKD.Tutorials')

.controller('WKD.Tutorials.Controller', [
  '$http',
  'WKD.Common.TutorialService',
  'orderByFilter',
  function ($http, tutorialService, orderBy) {
    var vm = this;

    $http.get('/video_tutorials').then(function (resp) {
      vm.videos = orderBy(resp.data.data, 'attributes.position');
    });

    vm.playVideo = function (video) {
      tutorialService.play(video.attributes.name, video.attributes.linkUrl);
    };
  }
])

;
