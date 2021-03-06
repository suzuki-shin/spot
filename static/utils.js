(function() {
  var _this = this,
    __slice = Array.prototype.slice;

  window.util = {};

  util.getParams = function(key) {
    var n, params, paramsInArray, _ref;
    _ref = location.search.split(/[\?\&]/).map(function(x) {
      return x.split('=');
    }), n = _ref[0], paramsInArray = 2 <= _ref.length ? __slice.call(_ref, 1) : [];
    params = {};
    paramsInArray.forEach(function(p) {
      return params[p[0]] = p[1];
    });
    return params[key];
  };

}).call(this);
