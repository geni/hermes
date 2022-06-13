function Hermes(opts) {
  var self = this;

  this.initialize = function(opts) {
    self.server         = opts.server;
    self.namespace      = opts.namespace || '';
    self.hermesPrepend  = "hermes-msg:"
    self.subscriptions  = {};

    self.resume();
  }

  this.onConnectionOpen = function(event) {
    if(console) console.log("[HERMES] Connection opened.");
    for(var topic in self.subscriptions) {
      if(!self.subscriptions[topic]) {
        self.ws.send(topic);
        self.subscriptions[topic] = true;
      }
    }
  }

  this.onConnectionClose = function(event) {
    if(console) console.log("[HERMES] Connection closed.");

    for(var topic in self.subscriptions) {
      self.subscriptions[topic] = false;
    }
  }

  this.onConnectionError = function(event) {
    if(console) console.log('[HERMES] Connection error:', event);
  }

  this.onServerMessage = function(event) {
    if(event.data == '')
        return;

    var msg = JSON.parse(event.data);
    msg.event = event;
    HermesEvents.publish(self.hermesPrepend + msg.subscription, [msg])
  }

  this.subscribe = function(topic, absolute, callback, name) {
    // absolute is optional, bypasses namespace
    topic     = (absolute != null && callback != null) ? topic : self.namespace + topic;
    callback  = callback || absolute;
    name      = name || "default";

    if(!topic) return;

    if(self.isPaused() || self.ws.readyState !== 1) {
      self.subscriptions[topic] = false;
    } else {
      self.ws.send(topic);
      self.subscriptions[topic] = true;
    }

    HermesEvents.subscribe(self.hermesPrepend + topic, name, callback);
  }

  this.pause = function() {
    if(self.isActive()) self.ws.close(1000);
    self.ws = null;
  }

  this.resume = function() {
    try {
      self.ws           = new WebSocket(self.server);
      self.ws.onmessage = self.onServerMessage.bind(self);
      self.ws.onopen    = self.onConnectionOpen.bind(self);
      self.ws.onclose   = self.onConnectionClose.bind(self);
      self.ws.onerror   = self.onConnectionError.bind(self);
    } catch(error) {
      if(console) console.error('[HERMES] Unable to create WebSocket: ', error);
      self.ws = null;
    }
  }

  this.reset = function() {
    self.pause();
    self.subscriptions = {};
    self.resume();
  }

  this.isActive = function() {
    return self.ws != null;
  },

  this.isPaused = function() {
    return self.ws == null;
  },

  this.initialize(opts);
}

// Simple Hermes PUBSUB Helper.
window.HermesEvents = (function (){
  var cache = {},

  publish = function (topic, args, scope) {
    if ( cache[topic] ) {
      for(var name in cache[topic]){
        cache[topic][name].apply( scope || this, args || []);
      }
    }
  },

  subscribe = function (topic, name, callback) {
    if ( !cache[topic] )
        cache[topic] = {};

    if ( cache[topic][name] )
      cache[topic][name] = null;

    cache[topic][name] = callback;
    return [topic, name, callback];
  }

  return {
    publish: publish,
    subscribe: subscribe,
    cache: cache
  };

}());

