var app = angular.module('sbAdminApp');
app.factory('toptal_config', function($rootScope,$window) {
	//console.log(sessionStorage.getItem('auth-token'));
    return {
        API_URL:'https://toptal.croftr.com/',
      	API_KEY: sessionStorage.getItem('auth-token'),
        siteurl : "http://localhost/hydra/app/#/",
        page_size : 20,
        max_size :5
    };

});
