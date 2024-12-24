require "spec"
require "http"
require "radix"

require "../src/kemal-routing-utils"

class AnnotationRouterRoutes < KemalRoutingUtils::AnnotationRouter
  @[GET("/")]
  def root(env)
    "Hello world from class"
  end
end

class AnnotationRouterRoutes2 < KemalRoutingUtils::AnnotationRouter
  @[GET("/two")]
  def root(env)
    "Hello world from class 2"
  end
end

module ModuleAnnotationRouterRoutes
  include KemalRoutingUtils::ModuleAnnotationRouter

  @[GET("/")]
  def self.root(env)
    "Hello world from module"
  end
end

# Taken from https://github.com/kemalcr/kemal/blob/master/spec/route_handler_spec.cr

def call_request_on_app(request)
  io = IO::Memory.new
  response = HTTP::Server::Response.new(io)
  context = HTTP::Server::Context.new(request, response)
  main_handler = build_main_handler
  main_handler.call context
  response.close
  io.rewind
  HTTP::Client::Response.from_io(io, decompress: false)
end

def build_main_handler
  Kemal.config.setup
  main_handler = Kemal.config.handlers.first
  current_handler = main_handler
  Kemal.config.handlers.each do |handler|
    current_handler.next = handler
    current_handler = handler
  end
  main_handler
end

Spec.before_each do
  config = Kemal.config
  config.env = "development"
  config.logging = false
end

Spec.after_each do
  Kemal.config.clear
  Kemal::FilterHandler::INSTANCE.tree = Radix::Tree(Array(Kemal::FilterHandler::FilterBlock)).new
  Kemal::RouteHandler::INSTANCE.routes = Radix::Tree(Kemal::Route).new
  Kemal::RouteHandler::INSTANCE.cached_routes = Hash(String, Radix::Result(Kemal::Route)).new
  Kemal::WebSocketHandler::INSTANCE.routes = Radix::Tree(Kemal::WebSocket).new
end
