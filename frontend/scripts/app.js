'use strict';
angular
    .module('sbAdminApp', [
        'oc.lazyLoad',
        'ui.router',
        'ui.bootstrap',
        'angular-loading-bar',
        'ngRoute',
        'uiGmapgoogle-maps',
        // "google.places",
        'toggle-switch',
        'sbAdminApp.services',
        'ng.deviceDetector',
    ])
    .config(['$stateProvider','$urlRouterProvider','$ocLazyLoadProvider','$httpProvider',function ($stateProvider,$urlRouterProvider,$ocLazyLoadProvider,$httpProvider) {

        $httpProvider.interceptors.push(function ($q, $location,toptal_config) {
            var cachedRequest = null;
            var smeCachedRequest = null;
            return {
                'request': function(config){
                    if(!config.url.includes("/login") && !config.url.includes("/signup")){
                        config.headers.Authorization = sessionStorage.getItem('auth-token');
                    }
                    return config;
                },
                'response': function (response) {
                    //Will only be called for HTTP up to 300
                    return response;
                },
                'responseError': function (rejection) {
                    if ($location.path() !== '/login') {
                        if (rejection.status === 403) {
                            console.log("unauthorized");
                            // $location.path('/dashboard/unauthorized');
                        }
                        if (rejection.status === 401) {
                            console.log("redirecting to login page..");
                            sessionStorage.clear();
                            localStorage.clear();
                            toptal_config.API_KEY = '';
                            $location.path('/login');
                            return rejection;
                        }
                        //return rejection;
                    }
                    return $q.reject(rejection);
                }
            };
        });
        $ocLazyLoadProvider.config({
            debug:false,
            events:true,
        });
        $stateProvider
            .state('dashboard', {
                url:'/dashboard',
                templateUrl: 'views/dashboard/main.html',
                resolve: {
                    depsParent: ['$ocLazyLoad', function ($ocLazyLoad) {
                        return $ocLazyLoad.load({
                            name: 'sbAdminApp',
                            files: [
                            'scripts/directives/header/header.js',
                            'scripts/directives/header/header-notification/header-notification.js',
                            'scripts/directives/sidebar/sidebar.js',
                            'scripts/directives/sidebar/sidebar-search/sidebar-search.js'
                        ]
                    }, {
                        name: 'toggle-switch',
                        files: [
                            "bower_components/angular-toggle-switch/angular-toggle-switch.min.js",
                            "bower_components/angular-toggle-switch/angular-toggle-switch.css"
                        ]
                    }, {
                        name: 'ngAnimate',
                        files: ['bower_components/angular-animate/angular-animate.js']
                    }, {
                        name: 'ngCookies',
                        files: ['bower_components/angular-cookies/angular-cookies.js']
                    }, {
                        name: 'ngResource',
                        files: ['bower_components/angular-resource/angular-resource.js']
                    }, {
                        name: 'ngSanitize',
                        files: ['bower_components/angular-sanitize/angular-sanitize.js']
                    }, {
                        name: 'ngTouch',
                        files: ['bower_components/angular-touch/angular-touch.js']
                    });
                }]}
            })
            .state('login',{
                templateUrl:'views/pages/login.html',
                url:'/login',
                resolve: {
                    loadMyFiles:function($ocLazyLoad) {
                        return $ocLazyLoad.load({
                            name:'sbAdminApp',
                            files:[
                                'scripts/controllers/login.js',
                            ]
                        })
                    }
                }
            })

            .state('dashboard.home',{
                url:'/home',
                //controller: 'MainCtrl',
                templateUrl:'views/dashboard/home.html',
                resolve: {
                    deps: ['$ocLazyLoad', 'depsParent', function($ocLazyLoad) {
                        return $ocLazyLoad.load({
                            name:'sbAdminApp',
                            files:[
                                'scripts/controllers/home.js'
                            ]
                        })
                    }]
                }
            })
            .state('dashboard.meals', {
                templateUrl: 'views/pages/meals.html',
                url: '/meals/{action: string}',
                params: {
                    id: null
                },
                resolve: {
                    deps: ['$ocLazyLoad', 'depsParent', function ($ocLazyLoad) {
                        return $ocLazyLoad.load({
                            name: 'sbAdminApp',
                            files: [
                                'scripts/controllers/meals.js',
                            ]
                        })
                    }]
                }
            })
            .state('dashboard.orders', {
                templateUrl: 'views/pages/orders.html',
                url: '/orders/{id: string}',
                params: {
                    id: null
                },
                resolve: {
                    deps: ['$ocLazyLoad', 'depsParent', function ($ocLazyLoad) {
                        return $ocLazyLoad.load({
                            name: 'sbAdminApp',
                            files: [
                                'scripts/controllers/orders.js',
                            ]
                        })
                    }]
                }
            })
            .state('dashboard.restaurant',{
                templateUrl:'views/pages/restaurant.html',
                url:'/restaurant/{rid: string}',
                params: {
                    rid: null
                },
                resolve: {
                    deps: ['$ocLazyLoad', 'depsParent',function($ocLazyLoad) {
                        return $ocLazyLoad.load({
                            name:'sbAdminApp',
                            files:[
                                'scripts/controllers/restaurant.js',
                            ]
                        })
                    }]
                }
            });


        // if none of the above states are matched, use this as the fallback
        $urlRouterProvider.otherwise('/login');
    }]);


