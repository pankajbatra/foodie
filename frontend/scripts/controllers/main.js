'use strict';

angular.module('sbAdminApp').controller('MainCtrl', function($state, $location, $scope,$http, $position, $rootScope, toptal_config, deviceDetector) {
    $rootScope.getAuthorization = function(){
        if(sessionStorage.getItem('auth-token') == null) {
            $location.path('/login');
        }
    };
    $scope.mediaClasses = deviceDetector.device + ' ' + deviceDetector.os + ' ' + deviceDetector.browser + ' ' + deviceDetector.browser_version;
    $rootScope.logout = function(){
        $http({
            method: 'DELETE',
            url: toptal_config.API_URL + 'logout'
        })
        .success(function(response, status, headers) {
            sessionStorage.clear();
            localStorage.clear();
            toptal_config.API_KEY = '';
            window.location =  '#/login';
        })
        .error(function(response, status, headers, config) {
            $scope.isValid = true;
            $scope.err_msg = response.error;
            console.log(response);
        });
    };
    $rootScope.setToptalConfig = function(arg){
        if(arg !== null && arg !== undefined){
            toptal_config.API_KEY = arg;
        }
    };

    if(localStorage.getItem('userSession') != null){
        getUserDetails(localStorage.getItem('userSession'));
    }
    $rootScope.getLoggedinDetails = function(userDetails){
        getUserDetails(userDetails);
    };

    function getUserDetails(userDetails){
        var user = JSON.parse(userDetails);
        $rootScope.user_loginId =  user.email;
    }

    // have Access to action
    $rootScope.hasPermissionTo = function(action){
        let result = false;
        let user = localStorage.getItem('userSession');
        user = JSON.parse(user);
        if(user) {
            let userPermissions = user.roles;
            angular.forEach(userPermissions, function(value, key) {
                if(value.name === action) {
                    result = true;
                }
            });
        }
        return result;
    }

}).controller('AlertsCtrl', function ($scope, $timeout, AlertsService) {
    $scope.alerts = AlertsService.msgs;
    $scope.getAlerts = function() {
        var alerts = {};
        for(var i = 0; i < arguments.length; i++) {
            alerts[arguments[i]] = $scope.alerts[arguments[i]];
        }
        return alerts;
    };
    $scope.addAlert = function(cat, type, msg) {
        AlertsService.addAlert(cat, type, msg)
    };
    $scope.closeAlert = function(cat, index) {
        AlertsService.closeAlert(cat, index);
    };
    $scope.autoDismiss = function(cat, index, timeout) {
        if("success" === AlertsService.msgs[cat][index].type || "warning" === AlertsService.msgs[cat][index].type) {
            if("undefined" == typeof timeout) {
                timeout = 5000;
            }
            $timeout(function() {
                $scope.closeAlert(cat, index);
            }, timeout);
        }
    }
}).filter('keys', keys);
function keys() {
    return function(items, fields) {
        var result = {};
        if(items) {
            angular.forEach(items, function(value, key) {
                if(-1 !== fields.indexOf(key)) {
                    result[key] = value;
                }
            });
        }
        return result;
    };
}
