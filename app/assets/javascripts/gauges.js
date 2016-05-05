window.Gauges = {
  _siteId: '',
  run: function() {
    if (typeof _gauges !== 'undefined') {
      _gauges.push(['track']);
    }
    else {
      window._gauges = [];
      var gauges = document.createElement('script');
      gauges.type  = 'text/javascript';
      gauges.async = true;
      gauges.id = 'gauges-tracker';
      gauges.setAttribute('data-site-id', this._siteId);
      gauges.src = 'https://secure.gaug.es/track.js';

      var firstScript = document.getElementsByTagName('script')[0];
      firstScript.parentNode.insertBefore(gauges, firstScript);
    }
  },
  setSiteId: function(siteId) {
    this._siteId = siteId;
    if (Turbolinks.supported) {
      document.addEventListener("turbolinks:load", function() {
        Gauges.run();
      });
    }
    else {
      Gauges.run();
    }
  }
};
