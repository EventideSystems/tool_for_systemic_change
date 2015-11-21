'use strict';


angular.module('WKD.Scorecards')

.controller('WKD.Scorecards.InitiativeController', [
  'flashr',
  'Restangular',
  'WKD.Common.DataModel',
  'WKD.Common.TutorialService',
  '$scope',
  'currentCard', //injected by resolve
  function (flashr, Restangular, dataModel, tutorialService, $scope, currentCard) {
    var vm = this;

    vm.initiatives = _.where(currentCard.included, { type: 'initiatives' });

    // @smell fair bit of controller to controller communication via events. refactor into services, pressed for time right now.
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

    $scope.showTutorial = function (char) {
      tutorialService.play(char.attributes.name, 'http://www.screencast.com/users/i1117863/folders/Default/media/9ca80a2e-f463-473b-aa09-858e910d5435/embed');
    };

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
