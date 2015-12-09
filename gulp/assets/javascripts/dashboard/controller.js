'use strict';


angular.module('WKD.Dashboard')

.controller('WKD.Dashboard.Controller', [
  'Restangular',
  'WKD.Common.TutorialService',
  function (Restangular, tutorialService) {
    var vm = this;

    Restangular.one('dashboard').get().then(function (dashboard) {
      vm.dashboard = dashboard;
    });

    Restangular.all('scorecards').getList({ limit: 5 }).then(function (sc) {
      vm.scorecards = sc;
    });

    vm.playVideo = function (title, url) {
      tutorialService.play('Example Video', 'http://www.screencast.com/users/i1117863/folders/Default/media/9ca80a2e-f463-473b-aa09-858e910d5435/embed');
    };
  }
]);
