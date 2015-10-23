'use strict';

angular.module('WKD.Common')

.factory('WKD.Common.DataModel', [
  function () {

    var factory = {}, cachedModel;

    factory.getFocusGroups = makeFindByFn('focus_area_groups');
    factory.getFocusAreas = makeFindByFn('focus_areas', 'focusAreaGroup');
    factory.getCharacteristics = makeFindByFn('characteristics', 'focusArea');

    // Builds the entire data model from 'included' data. The included data must be a flat array of all groups, areas and characteristics.
    factory.dataModelFrom = function (data) {
      // We cache result rather then looping same data for every initiative
      if (!cachedModel) {
        cachedModel = _.map(factory.getFocusGroups(data), function (group) {
          group.focusAreas = factory.getFocusAreas(data, group.id);
          group.focusAreas = _.map(group.focusAreas, function (area) {
            area.characteristics = factory.getCharacteristics(data, area.id);
            return area;
          });

          return group;
        });
      }

      return angular.copy(cachedModel);
    };

    // Assigns a checklist item to each characteristics on a model (in the context of an initiative). The checklist item tells us if a characteristic has been marked or comments made.
    factory.assignChecklistItems = function (model, items) {
      _.chain(model).pluck('focusAreas')
        .flatten().pluck('characteristics')
        .flatten().each(function (characteristic) {
          characteristic.checklistItem = _.find(items, {
            relationships: { characteristic: { data: {id: characteristic.id}} }
          });
        }).value();
    };

    factory.get = function () {
      return cachedModel;
    };

    function makeFindByFn(type, parentType) {
      return function (data, id) {
        var findBy = { type: type };
        // argh - the amount of wrapping from jsonapi makes it hard to follow
        if (id && parentType) {
          id = id.toString();
          findBy.relationships = {};
          findBy.relationships[parentType] = { data: { id: id } };
        }
        return _.sortBy(_.where(data, findBy), function (val) {
          return val.attributes.position;
        });
      };
    }

    return factory;
  }
]);
