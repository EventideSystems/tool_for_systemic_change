'use strict';

angular.module('WKD.Common', []);

require('./overrides.js');

// Services
require('./services/SidebarService.js');
require('./services/CurrentUserProvider.js');

// Directives
require('./directives/wkdSidebar.js');
require('./directives/wkdHeader.js');


// Mixins
require('./mixins/RESTController.js');


// Libs
require('./lib/flashr.js');
