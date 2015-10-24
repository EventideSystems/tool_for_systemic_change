var service, data, checklist;

describe('DataModel', function () {

  beforeEach(module('WKD'));

  beforeEach(module(function ($urlRouterProvider) {
    $urlRouterProvider.deferIntercept();
  }));

  beforeEach(inject(function ($injector) {
    service = $injector.get('WKD.Common.DataModel');
    data = window.MOCKS.dataModel;
    checklist = window.MOCKS.checklist;
  }));

  describe('finding', function () {
    it('should find all focus groups', function () {
      var groups = service.getFocusGroups(data);
      expect(groups.length).toBe(2);
      expect(groups[0].attributes.name).toEqual('Planned Exploitation of Community Knowledge, Ideas and Innovations');
    });

    it('should find all focus areas for a given group', function () {
      var areas = service.getFocusAreas(data, 1);
      expect(areas.length).toBe(2);
      expect(areas[0].attributes.name).toEqual('Community – government bureaucracy interface');
    });

    it('should find all characteristics for given area', function () {
      var chars = service.getCharacteristics(data, 8);
      expect(chars.length).toBe(1);
      expect(chars[0].attributes.name).toEqual('Gather, retain and reuse community knowledge and ideas in other contexts');
    });
  });

  describe('building', function() {
    it('should build the entire data model from included data', function () {
      var areas = service.dataModelFrom(data);
      expect(areas.length).toBe(2);
      expect(areas[1].focusAreas.length).toBe(1);
      expect(areas[1].focusAreas[0].characteristics.length).toBe(2);
    });

    it('should cache data model', function() {
      service.dataModelFrom(data);
      var spy = spyOn(_, 'map');
      service.dataModelFrom(data);

      expect(spy).not.toHaveBeenCalled();
    });
  });

  describe('assign', function() {
    var model;

    beforeEach(function () { model = service.dataModelFrom(data); });

    it('should assign checklist items to model characteristics', function () {
      service.assignChecklistItems(model, checklist);

      expect(model[0].focusAreas[0].characteristics[0].checklistItem.attributes.checked).toBe(true);
      expect(model[0].focusAreas[0].characteristics[0].checklistItem.attributes.comment).toEqual('foobar');
      expect(model[0].focusAreas[1].characteristics[1].checklistItem.attributes.checked).toBe(null);
      expect(model[0].focusAreas[1].characteristics[1].checklistItem.attributes.comment).toEqual('');
    });
  });
});
