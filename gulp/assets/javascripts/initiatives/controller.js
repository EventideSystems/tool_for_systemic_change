'use strict';


angular.module('WKD.Initiatives')

.controller('WKD.Initiatives.Controller', [
  '$state',
  'Restangular',
  'flashr',
  '$controller',
  '$scope',
  '$q',
  'WKD.Common.DataModel',
  'WKD.Common.TutorialService',
  '$http',
  function ($state, Restangular, flashr, $controller, $scope, $q, dataModel, tutorialService, $http) {
    var vm = this;
    var baseRef = Restangular.all('initiatives');

    $scope.showTutorial = function (char) {
      $http.get('/characteristics/' + char.id + '/video_tutorial').then(function (resp) {
        var data = resp.data;
        if (data) {
          tutorialService.play(data.data.attributes.name, data.data.attributes.linkUrl);
        }
      });
    };

    vm._list = function () {
      loadSharedResources();

      vm.initiative = { organisations: [] };
      vm.submitForm = create;
      vm.insideModal = !$state.current.name.match('initiatives');

      baseRef.getList().then(function (resp) {
        vm.initiatives = resp;
      });
    };

    vm._new = function () {
      loadSharedResources();
      vm.insideModal = true;
      vm.initiative = { organisations: [] };
      vm.submitForm = create;
      vm.action = 'list';
    };

    vm._view = function (params) {
      vm.submitForm = update;
      vm.deleteResource = destroy;

      loadSharedResources().then(function () {
        Restangular.one('initiatives', params.id).get().then(function (resp) {
          vm.initiative = unpack(resp);
        });
      });
    };

    vm._checklist = function (params) {
      vm._view(params);

      Restangular.one('initiatives', params.id)
        .getList('checklist_items').then(function (resp) {
          vm.focusGroups = dataModel.dataModelFrom(resp.included);
          dataModel.assignChecklistItems(vm.focusGroups, resp);
        });
    };

    vm._scorecard = function () {
      vm._new();
      vm.insideModal = true;
      vm.addToScorecard = true;
    };

    vm.newOrganisation = function () {
      vm.showNewOrgForm = true;
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

    $scope.$on('organisation:create', function (e, data) {
      data.ref.post(data.organisation).then(function (organisation) {
        vm.initiative.organisations.push(organisation);
        vm.showNewOrgForm = false;
        flashr.now.success('Organisation created');
      }, function (resp) {
        $scope.$broadcast('organisation:error', resp);
      });
    });

    $scope.$on('organisation:hideForm', function () {
      vm.showNewOrgForm = false;
    });

    $scope.$on('initiative:reset', function () {
      vm.initiative = {};
      vm.initiativeForm.$setUntouched();
    });

    $scope.$on('initiative:error', function (e, resp) {
      vm.errors = resp.data;
      flashr.now.error('Failed to create initiative');
    });

    $controller('WKD.Common.RESTController', { $scope: vm });

    ///////////////////////////////////////////////////////////////////////////

    function loadSharedResources() {
      return $q.all([
        Restangular.all('organisations').getList(),
        Restangular.all('scorecards').getList()
      ]).then(function (resp) {
        vm.organisations = resp[0];
        vm.scorecards = resp[1];
      });
    }

    function create() {
      if (vm.addToScorecard) {
        $scope.$emit('new:initiative', {
          ref: baseRef,
          initiative: pack(vm.initiative)
        });

        return;
      }

      if (vm.insideModal) return $scope.$close(pack(vm.initiative));

      return baseRef.post(pack(vm.initiative)).then(function (initiative) {
        vm.initiative = {};
        vm.initiativeForm.$setUntouched();
        vm.initiatives.push(initiative);
        flashr.now.success('Initiative successfully created!');
      }, function (resp) {
        vm.errors = resp.data;
        flashr.now.error('Failed to create initiative');
      });
    }

    function update() {
      return pack(vm.initiative).put().then(function () {
        flashr.now.success('Initiative updated!');
      }, function (resp) {
        vm.errors = resp.data;
        flashr.now.error('Failed to update initiative');
      });
    }

    function destroy() {
      if (!window.confirm('Are you sure you want to delete this?')) return;

      vm.initiative.remove().then(function () {
        flashr.later.success('Initiative deleted');
        $state.go('wkd.initiatives');
      });
    }

    function pack(initiative) {
      var packed = Restangular.copy(initiative);

      delete packed.organisations;
      delete packed.scorecard;

      packed.relationships = {
        organisations: { data: initiative.organisations },
        scorecard: { data: initiative.scorecard }
      };

      return packed;
    }

    function unpack(initiative) {
      var unpacked = Restangular.copy(initiative);

      unpacked.scorecard = _.find(vm.scorecards, {
        id: initiative.relationships.scorecard.data.id
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
