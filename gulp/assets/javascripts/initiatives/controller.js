'use strict';


angular.module('WKD.Initiatives')

.controller('WKD.Initiatives.Controller', [
  'WKD.Common.SidebarService',
  '$state',
  'Restangular',
  'flashr',
  '$controller',
  '$scope',
  '$q',
  function (sidebarService, $state, Restangular, flashr, $controller, $scope, $q) {
    var vm = this;
    var baseRef = Restangular.all('initiatives');
    var promise = $q.all([
      Restangular.all('organisations').getList(),
      Restangular.all('wicked_problems').getList()
    ]).then(function (resp) {
      vm.organisations = resp[0];
      vm.problems = resp[1];
    });

    vm._new = function () {
      vm.initiative = { organisations: [] };
      vm.submitForm = create;
      vm.insideModal = !$state.current.name.match('initiatives');
    };

    vm._view = function (params) {
      vm.submitForm = update;
      vm.deleteResource = destroy;

      promise.then(function () {
        Restangular.one('initiatives', params.id).get().then(function (resp) {
          vm.initiative = unpack(resp);
        });
      });
    };

    vm.addOrganisation = function () {
      if (_.find(vm.initiative.organisations,{id: vm.selectOrganisation.id})) {
        flashr.now.error('Organisation already added to this initiative.');
      } else {
        vm.initiative.organisations.push(vm.selectOrganisation);
      }

      vm.selectOrganisation = null;
    };

    vm.removeOrganisation = function (org) {
      _.remove(vm.initiative.organisations, org);
    };

    $controller('WKD.Common.RESTController', { $scope: vm });

    ///////////////////////////////////////////////////////////////////////////

    function create() {
      if (vm.insideModal) return $scope.$close(pack(vm.initiative));

      return baseRef.post(pack(vm.initiative)).then(function (initiative) {
        sidebarService.addLink(initiative);
        $state.go('^.view', { id: initiative.id });
        flashr.later.success('Initiative successfully created!');
      }, function (resp) {
        vm.errors = resp.errors;
        flashr.now.error('Failed to create initiative');
      });
    }

    function update() {
      return pack(vm.initiative).put().then(function () {
        sidebarService.updateLink(vm.initiative);
        flashr.now.success('Initiative updated!');
      });
    }

    function destroy() {
      if (!window.confirm('Are you sure you want to delete this?')) return;

      vm.initiative.remove().then(function () {
        flashr.later.success('Initiative deleted');
        $state.go('wkd.dashboard');
      });
    }

    function pack(initiative) {
      var packed = Restangular.copy(initiative);

      delete packed.organisations;
      delete packed.problem;

      packed.relationships = {
        organisations: { data: initiative.organisations },
        wickedProblem: { data: initiative.problem }
      };

      return packed;
    }

    function unpack(initiative) {
      var unpacked = Restangular.copy(initiative);

      unpacked.problem = _.find(vm.problems, {
        id: initiative.relationships.wickedProblem.data.id
      });

      unpacked.organisations = _.map(
        initiative.relationships.organisations.data, function (org) {
          return _.find(vm.organisations, { id: org.id });
        }
      );

      delete unpacked.relationships;

      return unpacked;
    }
  }
]);
