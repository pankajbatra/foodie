sbAdminApp = angular.module('sbAdminApp.services', []);

sbAdminApp.service('AlertsService', function() {
  this.msgs = {};
  this.addAlert = function(cat, type, msg, append) {
    if(!this.msgs[cat]) {
      this.msgs[cat] = [];
    }
    if(append) {
      this.msgs[cat].push({
        type: type,
        msg: msg
      });
    } else {
      this.msgs[cat] = [{
        type: type,
        msg: msg
      }];
    }
  };
  this.closeAlert = function(cat, t) {
    this.msgs[cat].splice(t, 1);
  };
});
