require "./spec_helper"

describe KemalRoutingUtils::AnnotationRouter do
  it "Can use annotations to define routes" do
    AnnotationRouterRoutes.new(false).register_all

    request = HTTP::Request.new("GET", "/")
    client_response = call_request_on_app(request)
    client_response.body.should eq("Hello world from class")
  end

  it "Can automatically include all AnnotationRouter routes into Kemal" do
    AnnotationRouterRoutes.new
    AnnotationRouterRoutes2.new

    KemalRoutingUtils.register_routes

    request = HTTP::Request.new("GET", "/")
    client_response = call_request_on_app(request)
    client_response.body.should eq("Hello world from class")

    request = HTTP::Request.new("GET", "/two")
    client_response = call_request_on_app(request)
    client_response.body.should eq("Hello world from class 2")
  end
end

describe KemalRoutingUtils::ModuleAnnotationRouter do
  it "Can use annotations to define routes" do
    ModuleAnnotationRouterRoutes.register_all

    request = HTTP::Request.new("GET", "/")
    client_response = call_request_on_app(request)
    client_response.body.should eq("Hello world from module")
  end
end
