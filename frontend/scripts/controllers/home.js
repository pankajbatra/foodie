'use strict';
/**
 * @ngdoc function
 * @name sbAdminApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the sbAdminApp
 */
angular.module('sbAdminApp')
	.controller('HomeCtrl', function($location,$scope,$state,$position,$rootScope,ConstantService,uiGmapIsReady,$timeout) {
		$rootScope.getAuthorization();
		$scope.hasPermissionTo = $rootScope.hasPermissionTo;
		$rootScope.userRest = JSON.parse(localStorage.getItem('restaurant'));
		$rootScope.ToptalPageTitle = 'Toptal Dashboard';
		if (!$rootScope.userRest) {
			$state.go('dashboard.restaurant');
		} else {
			$timeout(() => {
				$scope.map = {
					center: [parseFloat(localStorage.getItem('longitude')) || 77.046829, parseFloat(localStorage.getItem('latitude')) || 28.408996],
					zoom: 14
				};
				$scope.marker = {
					id: 0,
					coords: {
						latitude: parseFloat(localStorage.getItem('latitude')),
						longitude: parseFloat(localStorage.getItem('longitude'))
					},
					options: {
						labelClass: "marker-label",
						labelAnchor: "50 60",
						labelContent: "Your Restaurant",
						draggable: false,
						cursor: 'pointer',
						// animation: google.maps.Animation.DROP
					},
					icon: ConstantService.icons.restaurant
				};
			})
		}
	});
