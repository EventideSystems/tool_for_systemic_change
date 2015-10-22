'use strict';


angular.module('WKD.Scorecards')

.controller('WKD.Scorecards.NewController', [
  '$modal',
  'Restangular',
  'flashr',
  'WKD.Common.DefaultPacker',
  '$state',
  '$scope',
  'WizardHandler',
  function ($modal, Restangular, flashr, packer, $state, $scope, WizardHandler) {
    var vm = this;
    var baseRef = Restangular.all('scorecards');

    vm.newScorecard = { type: 'scorecards', initiatives: [], included: [] };

    Restangular.all('communities').getList().then(function (resp) {
      vm.communities = resp;
      vm.newScorecard.community = _.first(vm.communities);
    });

    Restangular.all('initiatives').getList().then(function (resp) {
      vm.initiatives = resp;
    });

    Restangular.all('wicked_problems').getList().then(function (resp) {
      vm.problems = resp;
      vm.newScorecard.problem = _.first(vm.problems);
    });

    // @smell Hack - for some reason $statechange is firing twice, i dont have time to figure out why.
    var preventDoubleTrigger = false;

    $scope.$on('$stateChangeStart', function (event) {
      if (preventDoubleTrigger) return preventDoubleTrigger = false;

      if (!vm.scorecardSaved && !!vm.newScorecard.name) {
        var answer = window.confirm('Your scorecard has not been created! Are you sure you want to navigate away? Your data will not be saved.');
        if (!answer) event.preventDefault();
      }

      preventDoubleTrigger = true;
    });



    vm.addSelectedInitiative = function () {
      if (_.find(vm.newScorecard.initiatives, {id: vm.selectInitiative.id})) {
        flashr.now.error('Initiative already exists on this scorecard');
      } else {
        vm.newScorecard.initiatives.push(vm.selectInitiative);
      }

      vm.selectInitiative = null;
    };

    vm.removeInitiative = function (initiative) {
      _.remove(vm.newScorecard.initiatives, initiative);
    };

    // Opens a modal for creating a new resource (community or initiative), reuses controller/template from /:resource/new to avoid duplication
    vm.openModal = function (resource) {
      var ctrl = 'WKD.' + _.capitalize(resource) + '.Controller';

      $modal.open({
        templateUrl: '/templates/scorecards/' + resource + '-modal.html',
        controller: ctrl,
        controllerAs: 'vm',
        size: 'lg'
      }).result.then(function (resp) {
        if (resource === 'communities') {
          vm.communities.push(resp);
          vm.newScorecard.community = resp;
        } else if (resource === 'problems') {
          vm.problems.push(resp);
          vm.newScorecard.problem = resp;
        } else {
          vm.newScorecard.initiatives.push(resp);
          vm.initiatives.push(resp);
        }
      });
    };

    vm.createScorecard = function () {
      return baseRef.post(pack(vm.newScorecard)).then(function (resp) {
        vm.scorecardSaved = true;
        $state.go('^.view', { id: resp.id });
        flashr.later.success('New scorecard created!');
      }, function () {
        // @todo: no error handling, add a global error interceptor
      });
    };

    vm.gotoStep = function (step) {
      WizardHandler.wizard('scorecard-wizard').goTo(step);
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
      packed.relationships.wickedProblem = packer.wrap({id:packed.problem.id});

      delete packed.community;
      delete packed.initiatives;
      delete packed.problem;

      return packed;
    }
  }
]);
