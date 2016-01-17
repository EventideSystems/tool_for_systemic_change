'use strict';

angular.module('WKD.Common')

.directive('wkdScorecardMatrix', [
  '$timeout',
  'WKD.Common.DataModel',
  '$modal',
  function ($timeout, dataModel, $modal) {
    return {
      restrict: 'E',
      transclude: true,
      scope: {
        initiatives: '=',
        scorecard: '='
      },
      link: function (scope, el) {
        var data = scope.initiatives.included;
        var checkListItems = _.where(data, { type: 'checklist_items' });
        var model = dataModel.dataModelFrom(data);

        scope.focusAreas = _.flatten(_.pluck(model, 'focusAreas'));
        scope.characteristics = _.flatten(_.pluck(scope.focusAreas, 'characteristics'));

        $timeout(function () { // waits for ngRepeat to finish
          // Colors all the cells
          el.find('.initiative').each(function (idx, init) {
            colorSet($(init).find('.cell'));
          });

          colorSet(el.find('.char-header'));

          function colorSet(set) {
            var total = 0;

            for (var i = 1; i <= scope.focusAreas.length; i++) {
              var prev, cur = scope.focusAreas[i - 1].characteristics.length;

              try { prev = scope.focusAreas[i - 2].characteristics.length; }
              catch (e) { prev = 0; }

              total += prev;

              set.slice(total, total + cur).addClass('color' + i);
            }
          }

          // Adds hovers - must be specific here with add/remove class. Toggle class was causing a bug where if you hover on init, the col active class was reversed
          el.find('.cell').add(el.find('.char-header')).hover(function () {
            $(this).column().addClass('active');
          }, function () {
            $(this).column().removeClass('active');
          });

          el.find('.legend').hover(function () {
            var cn = this.className.match(/(color\d)/);
            el.find('.' + cn[1]).addClass('active');
          }, function () {
            var cn = this.className.match(/(color\d)/);
            el.find('.' + cn[1]).removeClass('active');
          });

          el.find('.init-title').hover(function () {
            el.find('.grid-table')
              .find('[data-id=' + $(this).data('id') + ']')
              .addClass('active');
          }, function () {
            el.find('.grid-table')
              .find('[data-id=' + $(this).data('id') + ']')
              .removeClass('active');
          });
        });

        // Returns true if characteristic has not been checked for initiative
        scope.isGap = function (initiative, characteristic) {
          var item = findChecklistItemFor(initiative.id, characteristic.id);
          if (!item) return false;
          return !item.attributes.checked;
        };

        // using jquery here as ngClass would create too many watchers
        scope.toggleGaps = function () {
          el.find('.cell').toggleClass('inverse');
        };

        scope.printScorecard = function () {
          window.alert('Coming soon');
        };

        scope.openEmbedModal = function () {
          $modal.open({
            templateUrl: '/templates/scorecards/embed-modal.html',
            controller: ['scorecard', function (scorecard) {
              this.getEmbedUrl = function () {
                return '//' + window.location.host + '/#/scorecard/asdfasdf';
              };
            }],
            controllerAs: 'modal',
            resolve: { scorecard: scope.scorecard }
          });
        };

        function findChecklistItemFor(initId, charId) {
          return _.find(checkListItems, { relationships: {
            initiative: { data: { id: initId } },
            characteristic: { data: { id: charId }}
          } });
        }
      },
      templateUrl: '/templates/directives/wkd-scorecard-matrix.html'
    };
  }
]);
