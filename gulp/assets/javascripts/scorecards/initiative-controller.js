'use strict';


angular.module('WKD.Scorecards')

.controller('WKD.Scorecards.InitiativeController', [
  'flashr',
  'Restangular',
  'WKD.Common.DataModel',
  '$scope',
  'currentCard', //injected by resolve
  function (flashr, Restangular, dataModel, $scope, currentCard) {
    var vm = this;

    vm.initiatives = _.where(currentCard.included, { type: 'initiatives' });

    $scope.$on('new:initiative', function (e, data) {
      data.initiative.relationships.scorecard.data = currentCard;
      data.ref.post(data.initiative).then(function (initiative) {
        vm.initiatives.push(initiative);
        currentCard.included.push(initiative);
        flashr.now.success('New initiative added');
        $scope.$broadcast('initiative:reset');
      }, function (error) {
        $scope.$broadcast('initiative:error', error);
      });
    });

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
