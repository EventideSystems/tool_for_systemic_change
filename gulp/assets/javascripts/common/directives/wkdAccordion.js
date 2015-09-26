'use strict';

angular.module('WKD.Common.Accordion', [])

.animation('.slide-toggle', function () {
  return {
    beforeAddClass: function (el, cssClass, cb) {
      if (cssClass === 'ng-hide') el.slideUp(200, cb);
    },
    removeClass: function (el, cssClass, cb) {
      if (cssClass === 'ng-hide') {
        el.hide().slideDown(200, function () {
          el.css('overflow', 'initial');
          cb();
        });
      }
    }
  };
})

.directive('popoutAccordion', [
  function () {
    return {
      restrict: 'E',
      scope: {
        autoClose: '=',
      },
      controller: ['$rootScope', '$scope', function ($rootScope, $scope) {
        this.collapsePanels = function () {
          if ($scope.autoClose === false) return;
          $rootScope.$broadcast('popup-accordion:hide');
        };
      }],
      transclude: true,
      template: '<div class="popout-accordion" ng-transclude></div>'
    };
  }
])

.directive('popoutAccordionGroup', [
  function () {
    return {
      restrict: 'E',
      scope: {
        groupDisabled: '=',
        groupOpen: '='
      },
      controller: ['$scope', function ($scope) {
        var vm = this;

        $scope.$on('popup-accordion:hide', function () {
          if ($scope.groupOpen) return;
          vm.isOpen = false;
        });

        vm.checkOpen = function () {
          if (typeof $scope.groupOpen === "undefined") return vm.isOpen;
          return $scope.groupOpen;
        };

        vm.isDisabled = function () { return $scope.groupDisabled; };
      }],
      controllerAs: 'accordGroup',
      transclude: true,
      template: '<div ng-transclude class="accordion-group" ng-class="{ open: accordGroup.checkOpen(), disabled: groupDisabled }"></div>'
    };
  }
])

.directive('popoutAccordionPanel', [
  function () {
    return {
      restrict: 'E',
      scope: true,
      transclude: true,
      require: '^popoutAccordionGroup',
      link: function (scope, el, attrs, groupCtrl) {
        scope.$watch(
          function () { return groupCtrl.checkOpen(); },
          function (newVal) { scope.isOpen = newVal; }
        );
      },
      template: '<div class="accordion-panel slide-toggle" ng-show="isOpen" ng-transclude></div>'
    };
  }
])

.directive('popoutAccordionTitle', [
  function () {
    return {
      restrict: 'E',
      scope: true,
      transclude: true,
      template: '<div class="accordion-title" ng-transclude></div>'
    };
  }
])

.directive('popoutAccordionToggle', [
  function () {
    return {
      restrict: 'E',
      scope: {
        onToggle: '&'
      },
      transclude: true,
      require: ['^popoutAccordionGroup', '^popoutAccordion'],
      link: function (scope, els, attr, ctrls) {
        var accordGroup = ctrls[0],
            accord = ctrls[1];

        scope.togglePanel = function () {
          if (accordGroup.isDisabled()) return;

          if (accordGroup.isOpen) {
            accordGroup.isOpen = false;
          } else {
            accord.collapsePanels();
            accordGroup.isOpen = true;
          }

          if (scope.onToggle) scope.onToggle(accordGroup.isOpen);
        };
      },
      template: '<a href ng-click="togglePanel()" ng-transclude></a>'
    };
  }
])

;
