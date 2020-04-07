'use strict';
/**
 * @ngdoc function
 * @name sbAdminApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the sbAdminApp
 */
angular.module('sbAdminApp')
    .controller('ordersCtrl', function($state,$stateParams, $modal,$modalStack, $location, $route, $scope, $position, $rootScope, $http, toptal_config, AlertsService) {

        // set page title
        $rootScope.ToptalPageTitle = 'Orders';
        $rootScope.getAuthorization();
        $scope.modifiedOrder = {};

        $scope.max_size = toptal_config.max_size;
        $scope.page_size = toptal_config.page_size;
        $scope.isRestaurant = JSON.parse(localStorage.getItem('restaurant'));

        $scope.order = {};
        $scope.orders = [];
        $scope.restaurant = JSON.parse(localStorage.getItem('restaurant')) || [];
        $scope.init = function() {
            $scope.fetchOrders();
        };
        $scope.rejectReasons = ['OutOfStock', 'StoreClosed', 'DeliveryPerson', 'InvalidAddress', 'OutOfDeliveryArea', 'PaymentFailed', 'DamagedInTransit', 'UnDelivered'];
        $scope.button = {
            loading: false
        };
        $scope.totalItems = 0;
        $scope.currentPage = 1;

        $scope.fetchOrders = function() {
            $http({
                method: 'GET',
                url: toptal_config.API_URL + 'orders?page=' + $scope.currentPage
            })
                .success(function(response, status, headers) {
                    if (response.length>=20) $scope.totalItems = 22;
                    $scope.orders = response;
                })
                .error(function(response, status, headers, config) {
                    AlertsService.addAlert("orders", "danger", response.message);
                });
        };

        $scope.changeOrderStatus = function(order, status, isRest) {
            let data = {};
            if (isRest) {
                data = order;
                $scope.close();
            }
            else data = {
                "oid": order.oid,
                "status": status
            };
            $http({
                method: 'PATCH',
                url: toptal_config.API_URL + 'orders/update',
                data: JSON.stringify(data)
            })
                .success(function(response, status, headers) {
                    AlertsService.addAlert("orders", "success", "Meal status changed to " + order.status + " Successfully!");
                    $scope.fetchOrders();
                })
                .error(function(response, status, headers) {
                    AlertsService.addAlert("orders", "danger", response.message);
                });
        };
        $scope.changeOrder = function(order, status) {
            $scope.modifiedOrder = {
                "oid": order.oid,
                "status": status
            };
            $modal.open({
                animation: true,
                templateUrl: 'modal-change-status.html',
                size: 'md',
                scope: $scope
            });
        };
        $scope.blacklistUser = function (user) {
            if (!user.uid) return;
            $http({
                method: 'PATCH',
                url: toptal_config.API_URL + 'blacklist',
                data: {
                    "uid" : user.uid
                }
            })
                .success(function(response, status, headers) {
                    AlertsService.addAlert("orders", "success", "Meal status changed to " + order.status + " Successfully!");
                    $scope.fetchOrders();
                })
                .error(function(response, status, headers) {
                    AlertsService.addAlert("orders", "danger", response.message);
                });
        };
        $scope.close = function () {
            $modalStack.dismissAll();
        }
    });
