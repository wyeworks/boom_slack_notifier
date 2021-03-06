defmodule Support.TestController do
  use Phoenix.Controller
  import Plug.Conn

  defmodule TestException do
    defexception plug_status: 403, message: "booom!"
  end

  def index(_conn, _params) do
    raise TestException.exception([])
  end
end

defmodule Support.TestRouter do
  use Phoenix.Router
  import Phoenix.Controller

  use BoomNotifier,
    notifier: BoomSlackNotifier.SlackNotifier,
    options: [
      webhook_url: Application.get_env(:boom_slack_notifier, :test_webhook_url)[:value]
    ],
    custom_data: [:assigns, :logger]

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:save_custom_data)
  end

  scope "/" do
    pipe_through(:browser)
    get("/", Support.TestController, :index, log: false)
  end

  def save_custom_data(conn, _) do
    conn
    |> assign(:name, "Davis")
    |> assign(:age, 32)
  end
end
