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

    // Factory
    provider.$get = function () {
      var factory = {};

      factory.get = function () {
        return angular.copy(_currentUser); // dont allow caller to modify user
      };

      factory.hasRole = function (role) {
        return _currentUser.userRole === role;
      };

      return factory;
    };
  }
]);
