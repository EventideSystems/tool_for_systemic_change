'use strict';

angular.module('WKD.Common', ['WKD.Common.Accordion']);

require('./overrides.js');

// Services
require('./services/CurrentUserProvider.js');
require('./services/DefaultPacker.js');
require('./services/DataModel.js');
require('./services/TutorialService.js');

// Directives
require('./directives/wkdHeader.js');
require('./directives/wkdAccordion.js');
require('./directives/wkdActionPanel.js');
require('./directives/wkdHasRole.js');
require('./directives/wkdScorecardMatrix');

// Mixins
require('./mixins/RESTController.js');


// Libs
require('./lib/flashr.js');
require('./lib/plugins.js');



