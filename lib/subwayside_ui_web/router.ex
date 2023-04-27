defmodule SubwaysideUiWeb.Router do
  use SubwaysideUiWeb, :router

  pipeline :browser do
    @content_security_policy Enum.join(
                               [
                                 "default-src 'none'",
                                 "img-src 'self' data: cdn.mbta.com",
                                 "style-src 'self' 'unsafe-inline'",
                                 "script-src 'self' 'unsafe-inline'",
                                 "connect-src 'self'",
                                 "frame-src 'self'"
                               ],
                               "; "
                             )
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {SubwaysideUiWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers, %{"content-security-policy" => @content_security_policy}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Load balancer health check
  # Exempt from auth checks and SSL redirects
  scope "/", SubwaysideUiWeb do
    get "/_health", HealthController, :index
  end

  scope "/", SubwaysideUiWeb do
    pipe_through :browser

    get "/", PageController, :home
    live "/trains", TrainsLive
    live "/trains/:train_id", TrainsLive, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", SubwaysideUiWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:subwayside_ui, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SubwaysideUiWeb.Telemetry
    end
  end
end
