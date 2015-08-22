'use strict';

angular.module('WKD.Common')

.factory('WKD.Common.SidebarService', [
  'Restangular',
  'WKD.Common.ResourceFactory',
  function (Restangular, resourceFactory) {
    var service = {};

    // @todo derive title form resource
    service.CONTEXT_MENU = {
      Wicked_Problems: { title: 'Wicked Problems' },
      Organisations: { title: 'Organisations' },
      Communities: { title: 'Communities' },
      Initiatives: { title: 'Initiatives' }
    };

    service.currentSet = {};

    service.setLinks = function (links, ops) {
      service.currentSet.options = ops || null;
      service.currentSet.links = links || null;
    };

    service.isActive = function (resource) {
      try {
        return resource.toLowerCase().replace(/\s+/g, '') === service.currentSet.options.title.toLowerCase().replace(/\s+/g, '');
      } catch (e) {
        return false;
      }
    };

    _.each(service.CONTEXT_MENU, function (ops, resource) {
      var lowerCase = resource.toLowerCase(),
          camelCase = resource.replace('_', '');

      resourceFactory.createBase(camelCase, lowerCase);

      service['load' + camelCase] = function () {
        if (service.isActive(camelCase)) return;
        return resourceFactory.cache[camelCase].getList().then(function (resp) {
          service.setLinks(resp, _.extend({
            newState: 'wkd.' + lowerCase + '.new'
          }, ops));

          return resp;
        });
      };
    });

    return service;
  }
]);
