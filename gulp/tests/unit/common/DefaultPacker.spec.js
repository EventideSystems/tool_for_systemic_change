var service, obj;

describe('CurrentUserService', function () {

  beforeEach(module('WKD'));

  beforeEach(module(function ($urlRouterProvider) {
    $urlRouterProvider.deferIntercept();
  }));

  beforeEach(inject(function ($injector, _$httpBackend_) {
    service = $injector.get('WKD.Common.DefaultPacker');

    obj = {
      id: 12,
      name: 'foo',
      desc: 'bar',
      type: 'obj',
      relationships: [1, 2],
      included: ['baz', 'qux']
    };
  }));

  describe('packing', function () {
    var packed;

    beforeEach(function () {
      packed = service.packResource(obj);
    })

    it('should wrap all attributes in "data" except "included"', function () {
      expect(packed.data).toBeDefined();
      expect(packed.included[0]).toEqual('baz');
      expect(Object.keys(packed).length).toBe(2);
    });

    it('should not put data elements inside attributes', function () {
      expect(packed.data.attributes.relationships).toBeUndefined();
      expect(packed.data.relationships.length).toBe(2);
      expect(Object.keys(packed.data).length).toBe(4);
    });

    it('should wrap all non data elements in attributes', function () {
      expect(packed.data.attributes.name).toEqual('foo');
      expect(packed.data.desc).toBeUndefined();
    });

    it('will not wrap in data object if option is false', function() {
      var packed = service.packResource(obj, { wrap: false });
      expect(packed.data).toBeUndefined();
      expect(Object.keys(packed.attributes).length).toBe(2);
    });
  });

  describe('unpacking', function () {
    var unpacked;

    beforeEach(function () {
      unpacked = service.unpackResource(service.packResource(obj).data);
    });

    it('should remove attributes object', function () {
      expect(unpacked.name).toEqual('foo');
      expect(unpacked.attributes).toBeUndefined();
    });
  });
});
