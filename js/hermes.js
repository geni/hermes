
function Hermes(opts) {
  this.server         = opts.server;
  this.namespace      = opts.namespace || '';
  this.hermesPrepend  = "hermes-msg:"
  this.subscriptions  = {};

  this.resume();
}

Hermes.prototype = {

  onConnectionOpen: function() {
    for(var topic in this.subscriptions) {
      if(!this.subscriptions[topic]) {
        this.ws.send(topic);
        this.subscriptions[topic] = true;
      }
    }
  },

  onConnectionClose: function() {
    if(console) {
      console.log("[HERMES] Connection closed.")
    }

    for(var topic in this.subscriptions) {
      this.subscriptions[topic] = false;
    }
  },

  onServerMessage: function(e) {
    if(e.data == '') return;

    var msg = JSON.parse(e.data);
    msg.event = e; 
    HermesEvents.publish(this.hermesPrepend + msg.subscription, [msg])
  },

  subscribe: function(topic, absolute, callback, name) {
    // absolute is optional, bypasses namespace
    topic     = (absolute != null && callback != null) ? topic : this.namespace + topic;
    callback  = callback || absolute;
    name      = name || "default";

    if(this.ws.readyState !== 1) {
      this.subscriptions[topic] = false;
    } else {
      this.ws.send(topic);
      this.subscriptions[topic] = true;
    }

    HermesEvents.subscribe(this.hermesPrepend + topic, name, callback);
  },

  pause: function() {
    this.ws.close(1000);
    this.ws = null;
  },

  resume: function() {
    this.ws           = new WebSocket(this.server);
    this.ws.onmessage = this.onServerMessage.bind(this);
    this.ws.onopen    = this.onConnectionOpen.bind(this);
    this.ws.onclose   = this.onConnectionClose.bind(this);
  },

  isActive: function() {
    return this.ws != null;
  },

}

// Simple Hermes PUBSUB Helper.
window.HermesEvents = (function (){
  var cache = {},

  publish = function (topic, args, scope) {
    if(cache[topic]) {
      for(var name in cache[topic]){
        cache[topic][name].apply(scope || this, args || []);
      }
    }
  },

  subscribe = function(topic, name, callback) {
    if(!cache[topic])
        cache[topic] = {};

    if(cache[topic][name])
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
