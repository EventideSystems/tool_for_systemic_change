'use strict';

angular.module('WKD.Common')

.factory('WKD.Common.ResourceFactory', [
  'Restangular',
  function (Restangular) {
    var service = {};

    service.cache = {};

    service.createBase = function (name, url) {
      service.cache[name] = Restangular.all(url);
    };

    return service;
  }
]);
