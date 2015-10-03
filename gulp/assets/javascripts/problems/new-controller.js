'use strict';


angular.module('WKD.Problems')

.controller('WKD.Problems.NewController', [
  '$modal',
  'Restangular',
  'flashr',
  'WKD.Common.DefaultPacker',
  '$state',
  'WizardHandler',
  function ($modal, Restangular, flashr, packer, $state, WizardHandler) {
    var vm = this;
    var baseRef = Restangular.all('wicked_problems');

    vm.newProblem = { type: 'wicked_problems', initiatives: [], included: [] };

    Restangular.all('communities').getList().then(function (resp) {
      vm.communities = resp;
      vm.newProblem.community = _.first(vm.communities);
    });

    Restangular.all('initiatives').getList().then(function (resp) {
      vm.initiatives = resp;
    });

    vm.addSelectedInitiative = function () {
      if (_.find(vm.newProblem.initiatives, { id: vm.selectInitiative.id })) {
        flashr.now.error('Initiative already exists on this wicked problem');
      } else {
        vm.newProblem.initiatives.push(vm.selectInitiative);
      }

      vm.selectInitiative = null;
    };

    vm.removeInitiative = function (initiative) {
      _.remove(vm.newProblem.initiatives, initiative);
    };

    // Opens a modal for creating a new resource (community or initiative), reuses controller/template from /:resource/new to avoid duplication
    vm.openModal = function (resource) {
      var ctrl = 'WKD.' + _.capitalize(resource) + '.Controller';

      $modal.open({
        templateUrl: '/templates/problems/' + resource + '-modal.html',
        controller: ctrl,
        controllerAs: 'vm',
        size: 'lg'
      }).result.then(function (resp) {
        if (resource === 'communities') {
          vm.communities.push(resp);
          vm.newProblem.community = resp;
        } else {
          vm.newProblem.initiatives.push(resp);
          vm.initiatives.push(resp);
        }
      });
    };

    vm.createProblem = function () {
      return baseRef.post(pack(vm.newProblem)).then(function (resp) {
        $state.go('^.view', { id: resp.id });
        flashr.later.success('New wicked problem created!');
      }, function () {
        // @todo: no error handling, add a global error interceptor
      });
    };

    vm.gotoStep = function (step) {
      WizardHandler.wizard('problem-wizard').goTo(step);
    };

    /////////////////////////////////////////////////////////////////////////

    function pack(problem) {
      var packed = angular.copy(problem);

      packed.relationships = {};

      _.each(packed.initiatives, function (initiative) {
        initiative.type = 'initiatives';
        delete initiative.relationships.wickedProblem;
        initiative.relationships.organisations.data = _.map(
          initiative.relationships.organisations.data, function (org) {
            return { type: 'organisations', id: org.id };
          }
        );

        packed.included.push(packer.packResource(initiative, { wrap: false }));
      });

      packed.relationships.community = packer.wrap({id: packed.community.id});

      delete packed.community;
      delete packed.initiatives;

      return packed;
    }
  }
]);
