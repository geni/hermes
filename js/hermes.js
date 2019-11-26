function Hermes(opts) {
  var self = this;

  this.initialize = function(opts) {
    self.server         = opts.server;
    self.namespace      = opts.namespace || '';
    self.hermesPrepend  = "hermes-msg:"
    self.subscriptions  = {};

    self.resume();
  }

  this.onConnectionOpen = function() {
      for(var topic in self.subscriptions) {
      if(!self.subscriptions[topic]) {
        self.ws.send(topic);
        self.subscriptions[topic] = true;
      }
    }
  }

  this.onConnectionClose = function() {
    if(console) {
      console.log("[HERMES] Connection closed.")
    }

    for(var topic in self.subscriptions) {
      self.subscriptions[topic] = false;
    }
  }

  this.onServerMessage = function(e) {
    if(e.data == '')
        return;

    var msg = JSON.parse(e.data);
    msg.event = e; 
    HermesEvents.publish(self.hermesPrepend + msg.subscription, [msg])
  }

  this.subscribe = function(topic, absolute, callback, name) {
    // absolute is optional, bypasses namespace
    topic     = (absolute != null && callback != null) ? topic : self.namespace + topic;
    callback  = callback || absolute;
    name      = name || "default";

    if(self.ws.readyState !== 1) {
      self.subscriptions[topic] = false;
    } else {
      self.ws.send(topic);
      self.subscriptions[topic] = true;
    }

    HermesEvents.subscribe(self.hermesPrepend + topic, name, callback);
  }

  this.pause = function() {
    self.ws.close(1000);
    self.ws = null;
  }

  this.resume = function() {
    self.ws           = new WebSocket(self.server);
    self.ws.onmessage = self.onServerMessage.bind(self);
    self.ws.onopen    = self.onConnectionOpen.bind(self);
    self.ws.onclose   = self.onConnectionClose.bind(self);
  }

  this.isActive = function() {
    return self.ws != null;
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

