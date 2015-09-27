'use strict';

angular.module('WKD.Common')

.directive('wkdHasRole', [
  'WKD.Common.CurrentUser',
  function (currentUser) {
    return {
      restrict: 'A',
      priority: 9999,
      link: function (scope, el, attrs) {
        // @todo add super role check option eg, has-role="admin" returns true for staff
        if (!currentUser.hasRole(attrs.wkdHasRole)) el.remove();
      }
    };
  }
]);
