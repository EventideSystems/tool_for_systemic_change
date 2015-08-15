'use strict';

angular.module('WKD.Common')

.factory('WKD.Common.SidebarService', [
  'Restangular',
  function (Restangular) {
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

    _.each(service.CONTEXT_MENU, function (ops, resource) {
      var lowerCase = resource.toLowerCase(),
          camelCase = resource.replace('_', '');

      service['base' + camelCase] = Restangular.all(lowerCase + '.json');
      service['load' + camelCase] = function () {
        return service['base' + camelCase].getList().then(function (resp) {
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