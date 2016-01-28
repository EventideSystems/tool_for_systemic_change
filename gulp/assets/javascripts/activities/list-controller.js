'use strict';


angular.module('WKD.Activities')

.controller('WKD.Activities.ListController', [
  'Restangular',
  '$state',
  function (Restangular, $state) {
    var vm = this;
    var baseRef = Restangular.all('activities');

    var ACTION_ICON_MAP = {
      update: 'check',
      delete: 'times',
      create: 'plus'
    };

    var NAVIGATEABLE_EVENTS = ['WickedProblem'];

    baseRef.getList().then(function (logs) {
      vm.logs = logs;
    });

    vm.iconForEvent = function (log) {
      return 'fa-' + (ACTION_ICON_MAP[log.attributes.action] || 'history');
    };

    vm.canNavigate = function (log) {
      return _.contains(NAVIGATEABLE_EVENTS, log.attributes.trackableType);
    };

    vm.filterLogs = function () {
      // API dies if you send empty query param
      if (!vm.filter.trackable_type) delete vm.filter.trackable_type;

      baseRef.getList(vm.filter).then(function (logs) {
        vm.logs = logs;
      });
    };

    vm.gotoEvent = function (log) {
      var trackable = log.attributes.trackableType;
      // The only trackable that doesn't directly map to a ui state.
      if (trackable === 'WickedProblem') {
        $state.go('wkd.problems.view', { id: log.attributes.trackableId });
      } else {
        $state.go(
          'wkd.' + trackable, log.attributes.trackableId + 's.view',
          { id: log.attributes.trackableId }
        );
      }
    };
  }
])



;
