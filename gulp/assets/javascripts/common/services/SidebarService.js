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
    service.bases = {};

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

    service.addLink = function (link) {
      service.currentSet.links.push(link);
    };

    service.updateLink = function (updated) {
      var link = _.find(service.currentSet.links, { id: updated.id });
      if (link) link.attributes.name = updated.name;

    };

    _.each(service.CONTEXT_MENU, function (ops, resource) {
      var lowerCase = resource.toLowerCase(),
          camelCase = resource.replace('_', '');

      service.bases[camelCase] = Restangular.all(lowerCase);

      service['load' + camelCase] = function () {
        if (service.isActive(camelCase)) return;
        return service.bases[camelCase].getList().then(function (resources) {
          service.setLinks(resources, _.extend({
            newState: 'wkd.' + lowerCase + '.new',
            sref: 'wkd.' + lowerCase + '.view'
          }, ops));

          return resources;
        });
      };
    });

    return service;
  }
]);
