angular.module("WKD").run(["$templateCache", function($templateCache) {$templateCache.put("/templates/dashboard/index.html","<h1>Organisation\'s Dashboard</h1>\n\n<div class=\"widgets clearfix\">\n\n  <div class=\"col-sm-4 widget\">\n    <div class=\"inner\">\n      <header>\n        <strong>Welcome</strong>\n      </header>\n      <div class=\"content\">\n        <p>Hi YOUR NAME</p>\n        <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Obcaecati quisquam, dicta recusandae pariatur reprehenderit, possimus rem ipsam mollitia qui ipsum at atque provident facilis odio architecto quae quas perspiciatis ratione.</p>\n\n        <button class=\"btn btn-default\">Manage profile</button>\n      </div>\n    </div>\n  </div>\n\n  <div class=\"col-sm-4 widget\">\n    <div class=\"inner\">\n      <header>\n        <strong>Statistics</strong>\n      </header>\n      <div class=\"content\">\n        <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Obcaecati quisquam, dicta recusandae pariatur reprehenderit, possimus rem ipsam mollitia qui ipsum at atque provident facilis odio architecto quae quas perspiciatis ratione.</p>\n      </div>\n    </div>\n  </div>\n\n  <div class=\"col-sm-4 widget\">\n    <div class=\"inner\">\n      <header>\n        <strong>Recent Activity</strong>\n      </header>\n      <div class=\"content\">\n        <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit. Obcaecati quisquam, dicta recusandae pariatur reprehenderit, possimus rem ipsam mollitia qui ipsum at atque provident facilis odio architecto quae quas perspiciatis ratione.</p>\n\n        <button class=\"btn btn-default\">View all activity</button>\n      </div>\n    </div>\n  </div>\n</div>\n\n<div class=\"tutorials\">\n  <h2>Tutorials</h2>\n</div>");
$templateCache.put("/templates/directives/wkd-header.html","<header id=\"header\">\n\n  <span class=\"logo\">\n    <img src=\"/assets/images/logo.png\" alt=\"Wicked Labs\">\n  </span>\n\n  <nav class=\"sub-nav\">\n    <ul>\n      <li>\n        <a href ng-click=\"logout()\">Logout</a>\n      </li>\n    </ul>\n  </nav>\n\n</header>");
$templateCache.put("/templates/directives/wkd-sidebar.html","<aside id=\"sidebar\">\n  <h4 class=\"title\">\n    <a href class=\"new-resource\" ng-click=\"gotoNewForm()\" title=\"Create\">\n      <i class=\"fa fa-plus\"></i>\n    </a>\n\n    <div class=\"btn-group context-switcher\" dropdown is-open=\"status.isopen\">\n      <button id=\"context-dropdown\" type=\"button\" class=\"btn btn-default\" dropdown-toggle ng-disabled=\"disabled\">\n        {{ sidebar.options.title }} <span class=\"caret\"></span>\n      </button>\n      <ul class=\"dropdown-menu\" role=\"menu\" aria-labelledby=\"context-dropdown\">\n        <li role=\"menuitem\" ng-repeat=\"(key, ops) in contextMenu\">\n          <a href ng-click=\"load(key)\">{{ ops.title }}</a>\n        </li>\n      </ul>\n    </div>\n  </h4>\n\n  <div class=\"context-filter\">\n    <i class=\"fa fa-search\"></i>\n    <input type=\"text\" ng-model=\"search.text\" ng-attr-placeholder=\"Filter {{ sidebar.options.title }}\">\n  </div>\n</aside>");
$templateCache.put("/templates/layout/main-nav.html","<ul class=\"menu-items\">\n  <li>\n    <a ui-sref=\"wkd.dashboard\" ui-sref-active=\"active\">\n      <i class=\"fa fa-dashboard\"></i>\n      <span class=\"text\">Dashboard</span>\n    </a>\n  </li>\n  <li>\n    <a href=\"#/scorecards\">\n      <i class=\"fa fa-check-square-o\"></i>\n      <span class=\"text\">Scorecards</span>\n    </a>\n  </li>\n  <li>\n    <a href=\"#/users\">\n      <i class=\"fa fa-users\"></i>\n      <span class=\"text\">Users</span>\n    </a>\n  </li>\n  <li>\n    <a href=\"#/settings\">\n      <i class=\"fa fa-cogs\"></i>\n      <span class=\"text\">Settings</span>\n    </a>\n  </li>\n</ul>");
$templateCache.put("/templates/organisations/new.html","<h1>New organisation</h1>\n\n<form ng-submit=\"vm.submitForm()\" class=\"form-horizontal\">\n  <div class=\"form-group\">\n    <label for=\"org-name\" class=\"col-sm-4 control-label\">Organisation Name</label>\n\n    <div class=\"col-sm-8\">\n      <input type=\"text\" ng-model=\"vm.organisation.name\" class=\"form-control\" id=\"org-name\" placeholder=\"enter organisation name\">\n    </div>\n  </div>\n\n  <div class=\"form-group\">\n    <label for=\"org-website\" class=\"col-sm-4 control-label\">Website</label>\n\n    <div class=\"col-sm-8\">\n      <input type=\"text\" ng-model=\"vm.organisation.weblink\" class=\"form-control\" id=\"org-website\" placeholder=\"enter website\">\n    </div>\n  </div>\n\n  <div class=\"form-group\">\n    <label for=\"org-sector\" class=\"col-sm-4 control-label\">Description</label>\n\n    <div class=\"col-sm-8\">\n      <textarea class=\"form-control\" ng-model=\"vm.organisation.description\" placeholder=\"enter description\"></textarea>\n    </div>\n  </div>\n\n  <div class=\"col-sm-offset-4\">\n    <button type=\"submit\" class=\"btn btn-primary\">\n      Create organisation\n    </button>\n  </div>\n\n\n\n</form>");}]);