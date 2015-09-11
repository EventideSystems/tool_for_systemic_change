'use strict';

angular.module('WKD.Common')

// @todo - just dumping this here for now, should probably be populated by api
.factory('WKD.Common.DataModel', [
  function () {
    return {
      focusGroups: [
        {
          title: 'Unlock Complex Adaptive System Dynamics'
        },
        {
          title: 'Unplanned Exploration of Solutions with Communities'
        },
        {
          title: 'Planned Exploitation of Community Knowlede, Ideas and Innovations'
        }
      ]
    };
  }
]);
