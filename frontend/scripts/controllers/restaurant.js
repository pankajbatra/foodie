'use strict';
/**
 * @ngdoc function
 * @name sbAdminApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the sbAdminApp
 */
angular.module('sbAdminApp')
    .controller('restaurantCtrl', function($state,$stateParams, $modal,$modalStack, $location, $route, $scope,uiGmapIsReady, $position, $rootScope, $http, toptal_config, AlertsService,$timeout) {

        // set page title
        $rootScope.ToptalPageTitle = 'Restaurant Details';

        $rootScope.getAuthorization();
        $scope.createUser = false;
        $scope.showCancel = false;
        if(localStorage.getItem('cart')){
            $scope.cart = JSON.parse(localStorage.getItem('cart'));
        } else {
            $scope.cart = {
                items: 0,
                total_bill_amount: 0,
                cartItems: {}
            };
        }
        let userSession = JSON.parse(localStorage.getItem('userSession'));
        $scope.cust = {
            'customer_name': userSession.name,
            'customer_mobile': +userSession.mobile,
        };
        $scope.hasPermissionToRestaurant = $rootScope.hasPermissionTo('restaurant');
        $scope.storedRestaurant = JSON.parse(localStorage.getItem('restaurant')) || {};
        if ($scope.storedRestaurant && $scope.storedRestaurant.cuisines) {
            $scope.storedRestaurant.cuisine_ids = $scope.storedRestaurant.cuisines.map(c=>c['id']);
        }
        if (!$scope.storedRestaurant.rid) {
            $scope.createUser = true;
        }
        $scope.viewRestaurantDetails = false;
        $scope.init = function() {
            if ($scope.hasPermissionToRestaurant) {
                $scope.fetchCuisines();
                if ($scope.storedRestaurant && $scope.storedRestaurant.rid) $timeout(() => $scope.fetchRestaurant($scope.storedRestaurant.rid),0);
            }
            else {
                $rootScope.ToptalPageTitle = 'Restaurants';
                if (!$scope.viewRestaurantDetails) $scope.fetchRestaurantsForCustomer();
            }
        };
        $scope.button = {
            loading: false
        };
        $scope.max_size = toptal_config.max_size;
        $scope.page_size = toptal_config.page_size;
        $scope.currentPage = 1;
        $scope.totalItems = 0;
        $scope.restaurants = [];

        $scope.fetchCuisines = function() {
            $http({
                method: 'GET',
                url: toptal_config.API_URL + 'cuisines'
            })
                .success(function(response, status, headers) {
                    $scope.cuisines = response;
                    angular.forEach($scope.cuisines, function (val, key) {
                        if ($scope.storedRestaurant && $scope.storedRestaurant.cuisine_ids)
                            val.selected = !!($scope.storedRestaurant.cuisine_ids.includes(val.id));
                    });
                    $scope.cuisinesCopy = angular.copy($scope.cuisines);
                })
                .error(function(response, status, headers, config) {
                    AlertsService.addAlert("rest", "danger", response.message);
                });
        };
        $scope.fetchRestaurant = function(id, isCustomer) {
            $http({
                method: 'GET',
                url: toptal_config.API_URL + 'restaurants/get?rid=' + id
            })
                .success(function(response, status, headers) {
                    if (response && response.meals.length) {
                        response.meals = response.meals.map(meal => {
                            if ($scope.cart && $scope.cart.cartItems && $scope.cart.cartItems[meal.id])
                                meal["quantity"] = $scope.cart.cartItems[meal.id]['quantity'];
                            else
                                meal["quantity"] = 0;
                            return meal;
                        });
                    }
                    $scope.restaurant = response;
                    $scope.restaurant['latitude'] = +$scope.restaurant['latitude'];
                    $scope.restaurant['longitude'] = +$scope.restaurant['longitude'];
                    $scope.restaurant['tax_percent'] = +$scope.restaurant['tax_percent'];
                    $scope.restaurant['phone_number'] = +$scope.restaurant['phone_number'];
                    $scope.restaurant.cuisineNames = $scope.restaurant.cuisines.map(c=>c.name);
                    if (!isCustomer) {
                        $scope.restaurantCopy = angular.copy(response);
                        localStorage.setItem("restaurant", JSON.stringify($scope.restaurant));
                        localStorage.setItem("latitude", +$scope.restaurant['latitude']);
                        localStorage.setItem("longitude", +$scope.restaurant['longitude']);
                    }
                })
                .error(function(response, status, headers, config) {
                    AlertsService.addAlert("rest", "danger", response.message);
                });
        };
        $scope.fetchRestaurantsForCustomer = function() {
            $http({
                method: 'GET',
                url: toptal_config.API_URL + 'restaurants?page=' + $scope.currentPage
            })
                .success(function(response, status, headers) {
                    if (response.length){
                        angular.forEach(response, function (rest, key) {
                            rest.cuisines = rest.cuisines.map(c => c.name);
                        });
                    }
                    if (response.length>=20) $scope.totalItems = 22;
                    $scope.restaurants = response;
                })
                .error(function(response, status, headers, config) {
                    AlertsService.addAlert("rest", "danger", response.message);
                });
        };
        $scope.cancelEdit = function() {
            $scope.createUser = false;
            $scope.showCancel = false;
            $scope.cuisines = $scope.cuisinesCopy;
            $scope.restaurant =$scope.restaurantCopy;
        };
        $scope.runChecks = function(meal) {
            if ($scope.cart.cartItems.length && $scope.cart.rid && $scope.restaurant.rid !==$scope.cart.rid) {
                $modal.open({
                    animation: true,
                    templateUrl: 'modal-update-confirmation.html',
                    size: 'md',
                    scope: $scope
                });
                return true;
            }
            if (meal.status === 'OutOfStock') {
                $modal.open({
                    animation: true,
                    templateUrl: 'modal-out-of-stock.html',
                    size: 'sm',
                    scope: $scope
                });
                return true;
            }
            return false;
        };
        $scope.addMeal = function (res, meal) {
            if($scope.runChecks(meal)) return;
            if ($scope.cart.cartItems[meal.id]) meal.quantity= $scope.cart.cartItems[meal.id].quantity + 1;
            else meal.quantity= +1;
            $scope.cart.cartItems[meal.id] = {
                "meal_id": meal.id,
                "quantity": meal.quantity,
                "meal_name": meal.name,
                "price_per_item": meal.price,
                "sub_order_amount": parseFloat(meal.price) * meal.quantity
            };
            $scope.createCart(res);
        };
        $scope.removeMeal = function (res, meal) {
            if($scope.runChecks(meal)) return;
            if (meal.quantity > 0 && $scope.cart.cartItems[meal.id]) meal.quantity= $scope.cart.cartItems[meal.id].quantity-1;

            $scope.cart.cartItems[meal.id] = {
                "meal_id": meal.id,
                "quantity": meal.quantity,
                "meal_name": meal.name,
                "price_per_item": meal.price,
                "sub_order_amount": parseFloat(meal.price) * meal.quantity
            };
            if (meal.quantity === 0) delete $scope.cart.cartItems[meal.id];
            $scope.createCart(res);
        };
        $scope.createCart = function (res) {
            $scope.cart["rid"] = res.rid;
            $scope.cart["rest_min_del_amount"] = res.min_delivery_amount;
            $scope.cart["restaurant_address"] = res.address;
            $scope.cart["restaurant_name"] = res.name;
            $scope.cart["delivery_charge"] = res.delivery_charge;
            $scope.cart["packing_charge"] = res.packing_charge;

            $scope.cart['total_bill_amount'] = 0;
            $scope.cart.items = 0;
            angular.forEach($scope.cart.cartItems, function (meal) {
                if (meal.quantity) {
                    $scope.cart.total_bill_amount+= meal['sub_order_amount'];
                    $scope.cart.items += meal['quantity'];
                }
            });
            $scope.cart["tax_amount"] = (parseFloat(res['tax_percent'])*$scope.cart.total_bill_amount)/100;
            $scope.cart['total_bill_amount'] += parseFloat(res["delivery_charge"]) + parseFloat(res['packing_charge']);
            $scope.cart.total_bill_amount += $scope.cart["tax_amount"];
            localStorage.setItem('cart', JSON.stringify($scope.cart));
        };

        function isValidMobile(mobile) {
            let filter = /^[0-9]{10,15}$/;
            return filter.test(mobile);
        }
        $scope.createOrder = function(order){
            if (order["customer_mobile"] && !isValidMobile(order["customer_mobile"])) {
                AlertsService.addAlert("rest", "danger", 'kindly enter valid phone number (between 10 to 15 digits).');
                return;
            }
            order['rid'] = $scope.cart['rid'];
            order['tax_amount'] = $scope.cart['tax_amount'].toString();
            order['delivery_charge'] = $scope.cart['delivery_charge'];
            order['packing_charge'] = $scope.cart['packing_charge'];
            order['total_bill_amount'] = $scope.cart['total_bill_amount'].toString();
            let meals = [];
            angular.forEach($scope.cart.cartItems, function (meal, id) {
                meals.push(meal);
            });
            order['order_items_attributes'] = meals;
            $scope.button.loading = true;
            $http({
                method: 'POST',
                url: toptal_config.API_URL + '/orders',
                data: JSON.stringify(order)
            })
                .success(function(response, status, headers) {
                    AlertsService.addAlert("rest", "success", 'Order has been placed successfully.');
                    $scope.button.loading = false;
                    $timeout(() =>$scope.updateCart());
                    $state.go('dashboard.orders');
                })
                .error(function(response, status, headers) {
                    $scope.button.loading = false;
                    AlertsService.addAlert("rest", "danger", response.message);
                });
        };

        $scope.saveRestaurantDetails = function(data) {
            if(!$scope.createUser) {
                $scope.createUser = true;
                $scope.showCancel = true;
                return;
            }
            let cuisines = [];
            if (data["phone_number"] && !isValidMobile(data["phone_number"])) {
                AlertsService.addAlert("rest", "danger", 'kindly enter valid phone number (between 10 to 15 digits).');
                return;
            }
            if ($scope.cuisines.length) {
                angular.forEach($scope.cuisines, function(value, key){
                    if (value.selected) cuisines.push(value.id);
                });
            } else {
                AlertsService.addAlert("rest", "danger", 'kindly select atleast one cuisine.');
                return;
            }
            data['cuisine_ids'] = cuisines;
            $scope.button.loading = true;
            $http({
                method: $scope.storedRestaurant.rid? 'PUT':'POST',
                url: toptal_config.API_URL + ($scope.storedRestaurant.rid? 'restaurants/update' : 'restaurants'),
                data: JSON.stringify(data)
            })
                .success(function(response, status, headers) {
                    $scope.button.loading = false;
                    $scope.createUser = false;
                    $scope.showCancel = false;
                    $scope.fetchRestaurant($scope.storedRestaurant.rid?$scope.storedRestaurant.rid:response.rid);
                    AlertsService.addAlert("rest", "success", 'Restaurant has been updated successfully.');
                    // $timeout($state.go('dashboard.home'),1000);
                })
                .error(function(response, status, headers) {
                    $scope.button.loading = false;
                    AlertsService.addAlert("rest", "danger", response.message);
                });
        };
        $scope.changeStatus = function(status) {
            let openStatus = status? ' Opened': ' Closed';
            $http({
                method: 'PATCH',
                url: toptal_config.API_URL + 'restaurants/open',
                data: {
                    "rid" : $scope.restaurant.rid,
                    "open_for_delivery_now": status
                }
            })
                .success(function(response, status, headers) {
                    AlertsService.addAlert("rest", "success", "Restaurant" + openStatus + " Successfully!");
                    $scope.fetchRestaurant($scope.restaurant.rid);
                })
                .error(function(response, status, headers) {
                    AlertsService.addAlert("rest", "danger", response.message);
                });
        };
        $scope.checkout = function() {
            if ($scope.restaurant && ($scope.cart.total_bill_amount < $scope.cart.rest_min_del_amount)) {
                AlertsService.addAlert("meal", "danger", 'Minimum order amount is ' + $scope.cart.rest_min_del_amount + '/-');
                return;
            }
            $modal.open({
                animation: true,
                templateUrl: 'modal-checkout.html',
                size: 'lg',
                scope: $scope
            });
            $timeout(() =>{
            uiGmapIsReady.promise().then(function (maps) {
                $scope.customer_marker = {
                    id: 1,
                    coords: {
                        latitude: 28.408996,
                        longitude: 77.046829
                    },
                    options: {
                        labelClass: "marker-label",
                        labelAnchor: "50 60",
                        labelContent: "Drag Restaurant",
                        draggable: true,
                        cursor: 'pointer',
                        animation: google.maps.Animation.DROP
                    },
                    events: {
                        dragend: function(marker, eventName, args) {
                            $scope.cust.latitude = marker.getPosition().lat();
                            $scope.cust.longitude = marker.getPosition().lng();
                        }
                    },
                    icon: ConstantService.icons.customer
                };
            })},1000);
        };
        $scope.restaurantDetailPage = function (rest) {
            if (rest.open_for_delivery_now)
                $state.go('dashboard.restaurant',{'rid':rest.rid});
        };
        $scope.updateCart = function () {
            $scope.cart = {
                items: 0,
                total: 0,
                cartItems: {}
            };
            $scope.close();
            localStorage.setItem('cart', JSON.stringify($scope.cart));
        };
        $scope.close = function () {
            $modalStack.dismissAll();
        };
        $scope.marker = {
            id: 0,
            coords: {
                latitude: parseFloat($scope.storedRestaurant.latitude) || 28.408996,
                longitude: parseFloat($scope.storedRestaurant.longitude) || 77.046829
            },
            options: {
                labelClass: "marker-label",
                labelAnchor: "50 60",
                labelContent: "Drag Restaurant",
                draggable: true,
                cursor: 'pointer',
                animation: google.maps.Animation.DROP
            },
            events: {
                dragend: function(marker, eventName, args) {
                    $scope.restaurant.latitude = marker.getPosition().lat();
                    $scope.restaurant.longitude = marker.getPosition().lng();
                }
            },
            icon: ConstantService.icons.restaurant
        };
        $scope.initMap = function(lat, lng) {
            $scope.map = {
                center: [parseFloat($scope.storedRestaurant.longitude) || lng, parseFloat($scope.storedRestaurant.latitude) || lat],
                zoom: 13
            };
        };
        $scope.initMap(28.408996,77.046829);
        if($stateParams.rid && $stateParams.rid!=='all') {
            $scope.viewRestaurantDetails = true;
            $scope.storedRestaurant.rid = $stateParams.rid;
            $scope.fetchRestaurant($stateParams.rid, true);
        } else {
            $scope.viewRestaurantDetails = false;
        }
    });
