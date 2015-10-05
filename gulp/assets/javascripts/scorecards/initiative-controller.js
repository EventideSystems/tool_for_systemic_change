'use strict';


angular.module('WKD.Scorecards')

.controller('WKD.Scorecards.InitiativeController', [
  'flashr',
  'Restangular',
  'WKD.Common.DataModel',
  'currentCard', //injected by resolve
  function (flashr, Restangular, dataModel, currentCard) {
    var vm = this;

    vm.initiatives = _.where(currentCard.included, { type: 'initiatives' });

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
