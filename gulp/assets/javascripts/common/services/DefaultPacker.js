'use strict';

// @todo - this needs some decent tests

angular.module('WKD.Common')

.provider('WKD.Common.DefaultPacker', [
  function () {
    var provider = this;
    var ROOT_ELS = ['id', 'relationships', 'type'];

    // Wraps up a resource, ensures all props are where they belong
    provider.packResource = function (res, options) {
      var ops = _.extend({ wrap: true }, options);
      var packed = ops.wrap ? provider.wrap({}) : {};
      var data = packed.data || packed;

      data.attributes = res;

      _.each(ROOT_ELS, function (element) {
        if (element in res) {
          data[element] = res[element];
          delete data.attributes[element];
        }
      });

      if ('included' in res) {
        packed.included = res.included;
        delete data.attributes.included;
      }

      return packed;
    };

    provider.unpackResource = function (res) {
      res = _.extend({}, res, res.attributes);
      delete res.attributes;
      return res;
    };

    provider.wrap = function (data) {
      return { data: data };
    };

    // I see this mostly being used for interceptors, but just incase make methods avaliable to factory
    provider.$get = function () {
      return provider;
    };
  }
]);
