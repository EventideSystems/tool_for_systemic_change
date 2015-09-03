'use strict';

angular.module('WKD.Common', ['WKD.Common.Accordion']);

require('./overrides.js');

// Services
require('./services/SidebarService.js');
require('./services/CurrentUserProvider.js');
require('./services/DefaultPacker.js');

// Directives
require('./directives/wkdSidebar.js');
require('./directives/wkdHeader.js');
require('./directives/wkdAccordion.js');

// Mixins
require('./mixins/RESTController.js');


// Libs
require('./lib/flashr.js');



