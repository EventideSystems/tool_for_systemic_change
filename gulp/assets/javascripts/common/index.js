'use strict';

angular.module('WKD.Common', []);

require('./overrides.js');

// Services
require('./services/SidebarService.js');
require('./services/CurrentUserProvider.js');
require('./services/ResourceFactory.js');

// Directives
require('./directives/wkdSidebar.js');
require('./directives/wkdHeader.js');


// Controllers


// Libs
require('./lib/flashr.js');
