var provider, service, $httpBackend;

describe('CurrentUserService', function () {

  beforeEach(module('WKD', function ($injector) {
    provider = $injector.get('WKD.Common.CurrentUserProvider');
  }));

  beforeEach(module(function ($urlRouterProvider) {
    $urlRouterProvider.deferIntercept();
  }));

  beforeEach(inject(function ($injector, _$httpBackend_) {
    service = $injector.get('WKD.Common.CurrentUser');
    $injector.invoke(provider.resolveCurrentUser);
    $httpBackend = _$httpBackend_;

    // @todo factory
    $httpBackend.whenGET('/profile').respond(200, { data: {
      userName: 'foo',
      userRole: 'admin'
    }});

    $httpBackend.flush();
  }));

  it('should set current user', function () {
    expect(service.get().userName).toEqual('foo');
  });

  it('should not let you modify curent user', function () {
    var user = service.get();
    user.userRole = 'staff';
    expect(service.get().userRole).toEqual('admin');
  });

  it('should check if current user has role', function () {
    expect(service.hasRole('admin')).toBe(true);
    expect(service.hasRole('staff')).toBe(false);
  });
});
