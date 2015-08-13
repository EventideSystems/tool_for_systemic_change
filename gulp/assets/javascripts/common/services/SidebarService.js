'use strict';

angular.module('WKD.Common')

.factory('WKD.Common.SidebarService', [
  '$http',
  function ($http) {
    var service = {};

    service.currentSet = {};

    service.loadOrganisations = function () {
      return $http.get('/organisations.json').then(function (resp) {
        service.setLinks(resp.data, {
          title: 'Organisations',
          newState: 'organisations.new'
        });

        return resp.data;
      });
    };

    // @todo meta build fns
    service.loadProblems = function () {
      service.setLinks([], { title: 'Wicked Problems' });
    };

    service.loadCommunities = function () {
      service.setLinks([], { title: 'Communities' });
    };

    service.loadInitiatives = function () {
      service.setLinks([], { title: 'Initiatives' });
    };

    service.setLinks = function (links, ops) {
      service.currentSet.options = ops || null;
      service.currentSet.links = links || null;
    };

    return service;
  }
]);