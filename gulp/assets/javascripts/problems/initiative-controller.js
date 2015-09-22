'use strict';


angular.module('WKD.Problems')

.controller('WKD.Problems.InitiativeController', [
  'flashr',
  'Restangular',
  'WKD.Common.DataModel',
  'currentProblem', //injected by resolve
  function (flashr, Restangular, dataModel, currentProblem) {
    var vm = this;

    vm.initiatives = _.where(currentProblem.included, { type: 'initiatives' });

    vm.showChecklist = function (initiative) {
      if (initiative.$showChecklist) {
        initiative.$showChecklist = false;
        return;
      }

      _.each(vm.initiatives, function (ini) { ini.$showChecklist = false; });

      if (initiative.$focusGroups) {
        initiative.$showChecklist = true;
      } else {
        initiative.$loading = true;

        Restangular.one('initiatives', initiative.id)
          .getList('checklist_items').then(function (resp) {
            initiative.$loading = false;
            initiative.$showChecklist = true;
            initiative.$focusGroups = dataModel.dataModelFrom(resp.included);
            dataModel.assignChecklistItems(initiative.$focusGroups, resp);
          });
      }
    };

    /////////////////////////////////////////////////////////////////////////
  }
]);
