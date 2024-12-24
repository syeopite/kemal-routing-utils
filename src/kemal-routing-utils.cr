require "kemal"

# Kemal Routing Utils provides helper utilities to help define
# routes for an application in a more structured manner.
module KemalRoutingUtils
  private HTTP_METHODS = {"get", "post", "delete", "options", "patch", "put"}
  private ROUTERS      = [] of AnnotationRouter

  # Registers all routes into the application defined in `AnnotationRouter`s
  # initialized with `register_automatically` set to true into Kemal
  #
  #
  def self.register_routes
    ROUTERS.each(&.register_all)
  end

  # Namespace for annotations used to define routes for Kemal
  module RouteAnnotations
    {% for http_method in HTTP_METHODS %}
      # Annotation to create a route for a {{http_method.upcase}} request
      annotation {{http_method.upcase.id}}
      end
    {% end %}
  end

  # An `AnnotationRouter` allows an application to define routes through the use of
  # Crystal annotations in a manner similar to that of Python decorators.
  #
  # Simplify inherit from this abstract class and add any of the annotations:
  # `GET`, `POST`, `DELETE`, `OPTIONS`, `PATCH`, `PUT`
  #
  # With a positional argument for route and a route will be defined!
  #
  # ```
  # require "kemal"
  # require "kemal-routing-utils"
  #
  # class Routes < KemalRoutingUtils::AnnotationRouter
  #   @[GET("/")]
  #   def root(env)
  #     "Hello world"
  #   end
  # end
  #
  # Routes.new
  #
  # Kemal.run
  # ```
  #
  # ```
  # curl "http://0.0.0.0/" # => "Hello world"
  # ```
  #
  #
  # When the class is initialized the routes will be automatically registered into the Kemal application
  # when `KemalRoutingUtils.register_routes` is called.
  #
  # To disable this behavior just set the `register_automatically` argument to false when initializing the class.
  # After which you'll need to call `#register_all` manually to add the routes into the application
  abstract class AnnotationRouter
    include RouteAnnotations

    # Initializes a new AnnotationRouter which allows for defining routes using annotations
    #
    # When `register_automatically` is true the defined routes will be automatically included into
    # the application as soon as the class is initialized
    def initialize(register_automatically = true)
      ROUTERS << self if register_automatically
    end

    # Registers all the defined routes within this class into Kemal
    def register_all
      {% for method in @type.methods %}
        {% for route_identifier in method.annotations %}
          {% for http_method in HTTP_METHODS %}
            # If annotation denotes route handler

            if {{route_identifier.name.resolve}} == KemalRoutingUtils::AnnotationRouter::{{http_method.upcase.id}}
              Kemal::RouteHandler::INSTANCE.add_route({{http_method.upcase}}, {{route_identifier.args[0]}}) do | env |
                    self.{{method.name}}(env)
              end
            end
          {% end %}
        {% end %}
      {% end %}
    end
  end

  # Like an `AnnotationRouter` but for a module instead
  #
  # To use simply include this module into your route namespace
  #
  # ```
  # module Routes
  #   include KemalRoutingUtils::ModuleAnnotationRouter
  #
  #   @[GET("/")]
  #   def self.root(env)
  #     "Hello world"
  #   end
  # end
  # ```
  #
  # ```
  # curl "http://0.0.0.0/" # => "Hello world"
  # ```
  #
  # **You'll have to manually call #register_all to register the routes into the application**
  module ModuleAnnotationRouter
    include RouteAnnotations

    # Registers all the defined routes within this module into Kemal
    macro register_all
      {% for method in @type.class.methods %}
        {% for route_identifier in method.annotations %}
          {% for http_method in HTTP_METHODS %}
            # If annotation denotes route handler
            if {{route_identifier.name.resolve}} == {{@type}}::{{http_method.upcase.id}}
              Kemal::RouteHandler::INSTANCE.add_route({{http_method.upcase}}, {{route_identifier.args[0]}}) do | env |
                  {{@type}}.{{method.name}}(env)
                end
            end
          {% end %}
        {% end %}
      {% end %}
    end
  end
end
