'use strict';

angular.module('WKD.Common')

.provider('WKD.Common.CurrentUser', [
  function () {
    var provider = this, _currentUser;

    provider.resolveCurrentUser = ['Restangular', function (Restangular) {
      return Restangular.one('profile').get().then(function (user) {
        _currentUser = user;
        return user;
      });
    }];

    provider.hasRole = function (role) {
      // staff see all for now
      if (role !== 'staff' && provider.hasRole('staff')) return true;
      return _currentUser.userRole === role;
    };

    // Factory
    provider.$get = function () {
      var factory = {};

      factory.get = function () {
        return _currentUser;
      };

      factory.setClientName = function (name) {
        _currentUser.clientName = name;
      };

      factory.hasRole = provider.hasRole;

      return factory;
    };
  }
]);
