'use strict';

angular.module('WKD.Reports')

.controller('WKD.Reports.StakeholdersController', [
  '$http',
  'Restangular',
  function ($http, Restangular) {
    var vm = this;

    vm.openOptions = true;
    vm.report = {};

    Restangular.all('communities').getList().then(function (resp) {
      vm.communities = resp;
    });

    Restangular.all('wicked_problems').getList().then(function (resp) {
      vm.problems = resp;
    });


    vm.clear = function () {
      delete vm.report.problem;
      delete vm.report.community;
    };

    vm.generate = function () {
      var params = {};

      vm.report.data = null;

      if (vm.report.problem) params.wicked_problem_id = vm.report.problem.id;
      if (vm.report.community) params.community_id = vm.report.community.id;
      if (vm.report.sector) params.sector_id = vm.report.sector;

      vm.loading = true;

      $http.get('/reports/stakeholders', {
        params: params
      }).then(function (resp) {
        vm.report.data = resp.data.data;
        vm.loading = false;
        vm.openOptions = false;
      });
    };
  }
]);
