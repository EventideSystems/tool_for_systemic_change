var $compile, scope, element;

describe('Scorecard Matrix directive', function () {

  beforeEach(module('WKD'));

  beforeEach(module(function ($urlRouterProvider) {
    $urlRouterProvider.deferIntercept();
  }));

  beforeEach(inject(function(_$compile_, _$rootScope_, $timeout){
    $compile = _$compile_;
    scope = _$rootScope_;

    scope.initiatives = angular.copy(window.MOCKS.initiatives);
    scope.initiatives.included = window.MOCKS.dataModel.concat(window.MOCKS.checklist);

    element = $compile('<wkd-scorecard-matrix initiatives="initiatives"></wkd-scorecard-matrix>')(scope);
    scope.$digest();
    $timeout.flush();
  }));

  describe('render', function() {
    it('should render all initiatives', function() {
      expect(element.find('.initiative').length).toBe(scope.initiatives.length);
      expect(element.find('.init-title a').first().text()).toMatch(scope.initiatives[1].attributes.name);
    });

    it('should render all focus areas', function() {
      expect(element.find('.legend').length).toBe(3);
      expect(element.find('.legend').first().text()).toMatch('Focus area 1');
    });

    it('should render all characteristics foreach initiative', function() {
      expect(element.find('.cell').length).toBe(10);
    });

    it('should color the cells correctly', function() {
      expect(element.find('.cell.color1').length).toBe(2);
      expect(element.find('.cell.color2').length).toBe(4);
      expect(element.find('.cell.color3').length).toBe(4);
    });

    it('should correctly identify gaps', function() {
      expect(element.find('.initiative').first().find('.gap').length).toBe(2);
    });

    it('should toggle gaps on click', function() {
      expect(element.find('.inverse').length).toBe(0);
      element.find('.scorecard-matrix-controls .btn').click();
      expect(element.find('.inverse').length).toBe(10);
      element.find('.scorecard-matrix-controls .btn').click();
      expect(element.find('.inverse').length).toBe(0);
    });
  });
});
