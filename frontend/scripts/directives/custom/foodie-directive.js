'use strict';

angular.module('sbAdminApp')
  .directive('uppercase', function() {
   return {
     require: 'ngModel',
     link: function(scope, element, attrs, modelCtrl) {
        var uppercase = function(inputValue) {
           if(inputValue == undefined) inputValue = '';
           var uppercased = inputValue.toUpperCase();
           if(uppercased !== inputValue) {
              modelCtrl.$setViewValue(uppercased);
              modelCtrl.$render();
            }
            return uppercased;
         }
         modelCtrl.$parsers.push(uppercase);
         uppercase(scope[attrs.ngModel]);  // capitalize initial value
     }
   };
}).directive('specialCharacters', function() {
    function link(scope, elem, attrs, ngModel) {
        ngModel.$parsers.push(function(viewValue) {
            var reg = /^[a-zA-Z\s]+$/i;
            // if view values matches regexp, update model value
            if (viewValue && viewValue.match(reg)) {
                return viewValue;
            }
            // keep the model value as it is
            var transformedValue = ngModel.$modelValue;
            ngModel.$setViewValue(transformedValue);
            ngModel.$render();
            return transformedValue;
        });
    }

    return {
        restrict: 'A',
        require: 'ngModel',
        link: link
    };
}).constant("ConstantService", ConstantService);

angular.module('sbAdminApp')
  .directive('nospace', function() {
   return {
     require: 'ngModel',
     link: function(scope, element, attrs, modelCtrl) {
        var nospace = function(inputValue) {
           if(inputValue == undefined) inputValue = '';
           var nospaced = inputValue.trim().replace(' ', '_');
           if(nospaced !== inputValue) {
              modelCtrl.$setViewValue(nospaced);
              modelCtrl.$render();
            }
            return nospaced;
         };
         modelCtrl.$parsers.push(nospace);
         nospace(scope[attrs.ngModel]);  // capitalize initial value
     }
   };
}).directive('ngConfirmClick', [
    function(){
        return {
            priority: -1,
            restrict: 'A',
            link: function(scope, element, attrs){
                element.bind('click', function(e){
                    var message = attrs.ngConfirmClick;
                    // confirm() requires jQuery
                    if(message && !window.confirm(message)){
                        e.stopImmediatePropagation();
                        e.preventDefault();
                    }
                });
            }
        }
    }
]);

angular.module('sbAdminApp').directive('alertClose', function() {
   return {
     restrict: 'E',
     template: "<sapn class='close' data-dismiss='alert' aria-label='close'>&times;</span>"
   };
});
