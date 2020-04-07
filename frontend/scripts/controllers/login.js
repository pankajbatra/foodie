'use strict';
/**
 * @ngdoc function
 * @name sbAdminApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the sbAdminApp
 */
angular.module('sbAdminApp').controller('LoginCtrl', function($location, $route,$scope,$position, $rootScope, $http, toptal_config, AlertsService) {

	$scope.button = {
		loading: false,
		text: 'Login'
	};
	var chk_session = sessionStorage.getItem('auth-token');

	if(chk_session != null){
		$location.path('/dashboard/home')
	}
	else{
		$location.path('/login')
	}

	$scope.login = function(){
		$scope.button.loading = true;
		let loginCreds = {
			"email": $scope.username,
			"password": $scope.password
		};
  		$http({
			method: 'POST',
			url: toptal_config.API_URL + 'login',
			data: {
				"user": loginCreds
			}
		})
		.success(function(response, status, headers, config) {
			$scope.button.loading = false;
			AlertsService.addAlert("login", "success", "Login Successful. Loading Dashboard...");
			if (status === 200){
				setLoginSession(response,headers);
			}
		})
		.error(function(response,status, headers, config) {
			if (!response.errors) AlertsService.addAlert("login", "danger", response.error);
			else {
				angular.forEach(response.errors, function (val, key) {
					AlertsService.addAlert("login", "danger", key + ' ' + val.join(', '), true);
				})
			}
			$scope.button.loading = false;
		});

	};
	function setLoginSession(response, headers) {
		sessionStorage.setItem("auth-token", headers('authorization'));
		localStorage.setItem("userSession", JSON.stringify(response));
		if (response.restaurant) {
			if (response.restaurant.cuisines) response.restaurant.cuisine_ids = response.restaurant.cuisines.map(cuisine => cuisine["id"]);
			localStorage.setItem("restaurant", JSON.stringify(response.restaurant));
			localStorage.setItem("latitude", JSON.stringify(response.restaurant.latitude));
			localStorage.setItem("longitude", JSON.stringify(response.restaurant.longitude));
		}
		$rootScope.sessionKey = headers('authorization');
		$rootScope.userDetails = JSON.stringify(response);
		$rootScope.getLoggedinDetails($rootScope.userDetails);
		$rootScope.setToptalConfig($rootScope.sessionKey);
		$location.path('dashboard/home');
	}
	function isValidMobile(mobile) {
		let filter = /^[0-9]{10,15}$/;
		return filter.test(mobile);
	}
  	$scope.signup = function(){
		if (!isValidMobile($scope.mobile)) {
			AlertsService.addAlert("login", "danger", 'kindly enter valid phone number (between 10 to 15 digits).');
			return;
		}
		let signUpData = {
			"email": $scope.email,
			"password": $scope.signUpPassword,
			"name": $scope.name,
			"mobile": $scope.mobile
		};
		if ($scope.userType === 'Restaurant') signUpData["role_names"] = ["restaurant"];
		$scope.button.loading = true;
  		$http({
			method: 'POST',
			url: toptal_config.API_URL + 'signup',
			data: {
				"user": signUpData
			}
		})
		.success(function(response, status, headers, config) {
			$scope.button.loading = false;
			setLoginSession(response,headers);
		})
		.error(function(response,status, headers, config) {
			$scope.button.loading = false;
			if (!response.errors) AlertsService.addAlert("signup", "danger", response.error);
			else {
				angular.forEach(response.errors, function (val, key) {
					AlertsService.addAlert("signup", "danger", key + ' ' + val.join(', '), true);
				})
			}
		});
  	}
});
