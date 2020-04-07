'use strict';
/**
 * @ngdoc function
 * @name sbAdminApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the sbAdminApp
 */
angular.module('sbAdminApp')
    .controller('mealsCtrl', function($state,$stateParams, $modal, $location, $route, $scope, $position, $rootScope, $http, toptal_config, AlertsService) {

        // set page title
        $rootScope.ToptalPageTitle = 'Meals';
        $rootScope.getAuthorization();
        $scope.createMeal = false;
        $scope.editMeal = false;

        $scope.showCancelMeal = false;
        $scope.mealChecks = {
            regular: ['is_chef_special'],
            veg: ['is_veg','is_vegan'],
            nonveg: ['contains_egg','contains_meat']
        };
        $scope.meal = {};
        $scope.meals = {};
        $scope.restaurant = JSON.parse(localStorage.getItem('restaurant')) || [];
        $scope.init = function() {
            $scope.fetchMeals();
            $scope.fetchCuisines();
        };
        $scope.button = {
            loading: false
        };
        $scope.pageChanged = function() {
            $scope.fetchMeals();
        };

        $scope.fetchCuisines = function() {
            $http({
                method: 'GET',
                url: toptal_config.API_URL + 'cuisines'
            })
                .success(function(response, status, headers) {
                    $scope.cuisines = response;
                })
                .error(function(response, status, headers, config) {
                    AlertsService.addAlert("rest", "danger", response.message);
                });
        };

        $scope.fetchMeals = function() {
            $http({
                method: 'GET',
                url: toptal_config.API_URL + 'meals?rid=' + $scope.restaurant.rid
            })
                .success(function(response, status, headers) {
                    $scope.meals = response;
                    angular.forEach($scope.meals, function (meal, id) {
                        if (meal.status === 'Active') meal['setStatus'] = true;
                        else meal['setStatus'] = false;
                      if (meal['price']) meal['price'] = parseFloat(meal['price']);
                    });
                    if (!$scope.meals.length) $scope.createMeal = true;
                })
                .error(function(response, status, headers, config) {
                    AlertsService.addAlert("meals", "danger", response.message);
                });
        };
        $scope.cancelEdit = function() {
            $scope.createMeal = false;
            $scope.showCancelMeal = false;
            $scope.cuisines = $scope.cuisinesCopy;
            $scope.restaurant =$scope.restaurantCopy;
        };
        $scope.cancelCreateMeal = function() {
            $scope.createMeal = false;
            $scope.editMeal = false;
            $scope.meal = {};
        };

        $scope.editMealDetails = function(meal) {
            $scope.meal = angular.copy(meal);
            $scope.editMeal = true;
        };
        $scope.saveMeal = function(data) {
            if(!$scope.createMeal) {
                $scope.createMeal = true;
                $scope.showCancelMeal = true;
                return;
            }
            $scope.button.loading = true;

            $http({
                method: data.id? 'PUT':'POST',
                url: toptal_config.API_URL + (data.id? 'meals/'+data.id : 'meals'),
                data: JSON.stringify(data)
            })
                .success(function(response, status, headers) {
                    $scope.button.loading = false;
                    $scope.createMeal = false;
                    $scope.editMeal = false;
                    $scope.fetchMeals();
                    $scope.showCancelMeal = false;
                    AlertsService.addAlert("meals", "success", 'Meal has been updated successfully.');
                    // $timeout($state.go('dashboard.home'),1000);
                })
                .error(function(response, status, headers) {
                    $scope.button.loading = false;
                    AlertsService.addAlert("meals", "danger", response.message);
                });
        };

        $scope.changeStatus = function(meal) {
            const openStatus = meal.setStatus? 'Active': 'OutOfStock';
            $http({
                method: 'PATCH',
                url: toptal_config.API_URL + 'meals/' + meal.id,
                data: {
                    "status": openStatus
                }
            })
                .success(function(response, status, headers) {
                    AlertsService.addAlert("meals", "success", "Meal status changed to " + openStatus + " Successfully!");
                    $scope.fetchMeals();
                })
                .error(function(response, status, headers) {
                    AlertsService.addAlert("meals", "danger", response.message);
                });
        };
    });
