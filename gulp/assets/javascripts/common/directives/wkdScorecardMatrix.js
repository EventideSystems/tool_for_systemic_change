'use strict';

angular.module('WKD.Common')

.directive('wkdScorecardMatrix', [
  '$timeout',
  function ($timeout) {

    // Where to splice each td
    var MAPPING = [6, 14, 18, 22, 26, 29, 31, 34, 36];

    return {
      restrict: 'E',
      transclude: true,
      scope: {
        initiatives: '='
      },
      link: function (scope, el) {

        $timeout(function () {
          // @smell - WET
          el.find('.initiative').each(function (idx, init) {
            var $cells = $(init).find('.cell');

            for (var i = 1; i <= MAPPING.length; i++) {
              $cells
                .slice((MAPPING[i-2] || 0), MAPPING[i-1])
                .addClass('color' + i);
            }

            // Empty out 15 random cells
            for (var j = 1; j<=15; j++) {
              $cells.eq(Math.floor(Math.random() * $cells.length)).addClass('gap');
            }
          });

          var $chars = el.find('.char-header');

          for (var i = 1; i <= MAPPING.length; i++) {
            $chars
              .slice((MAPPING[i-2] || 0), MAPPING[i-1])
              .addClass('color' + i);
          }

          el.find('.cell').add(el.find('.char-header')).hover(function () {
            $(this).column().toggleClass('active');
          });

          el.find('.legend').hover(function () {
            var cn = this.className.match(/(color\d)/);
            el.find('.' + cn[1]).toggleClass('active');
          });

          el.find('.init-title').hover(function () {
            $(this).parent().find('.cell').toggleClass('active');
          });
        });

        // just randomly deciding if a gap for now
        scope.isGap = function () {
          return !(Math.round(Math.random() * 3));
        };

        // hardcoding until they can come fron endpoint
        scope.characteristics = [
          'frame issues to match diverse perspectives',
          'enable safe fail experimentation',
          'enable rich interactions in relational spaces',
          'support collective action',
          'partition the system',
          'establish network linkages',
          'highlight the need to organise communities differently',
          'cultivate a passion for action',
          'manage initial starting conditions',
          'specify goals in advance',
          'establish appropriate boundaries',
          'embrace uncertainty',
          'surface conflict',
          'create! controversy',
          'create! correlation through language and symbols',
          'encourage individuals to accept positions as role models for the change effort',
          'enable periodic information exchanges between partitioned subsystems',
          'enable resources and capabilities to recombine',
          'integrate local constraints',
          'provide a multiple perspective context and system structure',
          'enable problem representations to anchor in the community',
          'enable emergent outcomes to be monitored',
          'assist system members to keep informed and knowledgeable of forces influencing their community system',
          'assist in the connection, dissemination and processing of information',
          'enable connectivity between people who have different perspectives on community issues',
          'retain and reuse knowledge and ideas generated through interactions',
          'assist public administrators to frame policies in a manner which enables community adaptation of policies',
          'remove information differences to enable the ideas and views of citizens to align to the challenges being addressed by governments',
          'encourage and assist street level workers to take into account the ideas and views of citizens',
          'assist elected members to frame policies in a manner which enables community adaptation of policies',
          'assist elected members to take into account the ideas and views of citizens',
          'encourage and assist street level workers to exploit the knowledge, ideas and innovations of citizens',
          'bridge community-led activities and projects to the strategic plans of governments',
          'gather, retain and reuse community knowledge and ideas in other contexts',
          'encourage and assist elected members to exploit the knowledge, ideas and innovations of citizens  ',
          'collect, analyse, synthesise, reconfigure, manage and represent community information that is relevant to the electorate or area of portfolio responsibility of elected members'
        ];
      },
      templateUrl: '/templates/directives/wkd-scorecard-matrix.html'
    };
  }
]);
