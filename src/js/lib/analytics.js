var k = this;
function l(a) {
  var c = ["yext", "analytics", "getYextAnalytics"], b = k;
  c[0] in b || !b.execScript || b.execScript("var " + c[0]);
  for (var d;c.length && (d = c.shift());) {
    c.length || void 0 === a ? b = b[d] ? b[d] : b[d] = {} : b[d] = a;
  }
}
;(function(a, c) {
  function b(b, d) {
    function a(b) {
      d(b);
    }
    var e = c.createElement("img");
    d && (e.onload = a, e.onerror = e.onabort = a);
    e.src = b;
    e.style.width = "0";
    e.style.height = "0";
    e.style.position = "absolute";
    c.body.appendChild(e);
  }
  var d = a.location.protocol + "//www.yext-pixel.com/";
  l(function(a) {
    return function(m, n) {
      a.pagesReferrer = c.referrer;
      a.pageurl = c.location.pathname;
      a.eventType = m;
      var e = d + ("campaign_pages" === a.product ? "campaign_pagespixel" : "store_pagespixel"), f = "", g = 0;
      a.v = Date.now() + Math.floor(1E3 * Math.random());
      for (var h in a) {
        f += 0 === g ? "?" : "\x26", f = f + h + "\x3d" + a[h], g += 1;
      }
      b(e + f, n);
    };
  });
})(window, document);

