'use strict';

angular.module('WKD.Reports')

.controller('WKD.Reports.InitiativesController', [
  '$http',
  'Restangular',
  function ($http, Restangular) {
    var vm = this;

    vm.openOptions = true;

    Restangular.all('communities').getList().then(function (resp) {
      vm.communities = resp;
    });

    Restangular.all('wicked_problems').getList().then(function (resp) {
      vm.problems = resp;
    });

    vm.report = {
      communities: [],
      problems: []
    };

    // @smell - almost identical functions
    vm.addCommunity = function () {
      if (_.find(vm.report.communities, vm.newCommunity)) return;
      vm.report.communities.push(vm.newCommunity);
      vm.newCommunity = null;
    };

    vm.addProblem = function () {
      if (_.find(vm.report.problems, vm.newProblem)) return;
      vm.report.problems.push(vm.newProblem);
      vm.newProblem = null;
    };

    vm.remove = function (collection, entity) {
      _.remove(vm.report[collection], entity);
    };

    vm.clear = function () {
      vm.report.communities = [];
      vm.report.problems = [];
    };

    vm.generate = function () {
      vm.loading = true;
      vm.report.data = null;

      return $http.get('/reports/initiatives', {
        params: getReportParams()
      }).then(function (resp) {
        vm.openOptions = false;
        vm.loading = false;
        vm.report.data = resp.data.data; // .data.data.data!!!!
      });
    };

    function getReportParams() {
      var params = {}, report = vm.report;

      if (report.problems.length) {
        params.wicked_problem_id = _.pluck(report.problems, 'id').join(',');
      }

      if (report.communities.length) {
        params.community_id = _.pluck(report.communities, 'id').join(',');
      }

      return params;
    }
  }
]);
