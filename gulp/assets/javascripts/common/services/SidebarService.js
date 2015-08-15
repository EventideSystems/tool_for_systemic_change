'use strict';

angular.module('WKD.Common')

.factory('WKD.Common.SidebarService', [
  'Restangular',
  function (Restangular) {
    var service = {};

    service.CONTEXT_MENU = {
      Problems: { title: 'Wicked Problems' },
      Organisations: { title: 'Organisations' },
      Communities: { title: 'Communities' },
      Initiatives: { title: 'Initiatives' }
    };

    service.currentSet = {};

    service.setLinks = function (links, ops) {
      service.currentSet.options = ops || null;
      service.currentSet.links = links || null;
    };

    _.each(service.CONTEXT_MENU, function (ops, resource) {
      var lowerResource = resource.toLowerCase();

      service['base' + resource] = Restangular.all(lowerResource + '.json');
      service['load' + resource] = function () {
        return service['base' + resource].getList().then(function (resp) {
          service.setLinks(resp, _.extend({
            newState: 'wkd.' + lowerResource + '.new'
          }, ops));

          return resp;
        });
      };
    });

    return service;
  }
]);