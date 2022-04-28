defmodule BoomSlackNotifier.SlackNotifier do
  @moduledoc """
  Send exception notifications as slack messages through http requests

  ## Usage
  ```elixir
  defmodule YourApp.Router do
  use Phoenix.Router

  use BoomNotifier,
    notifier: BoomSlackNotifier.SlackNotifier,
    options: [
      webhook_url: "<your-slack-generated-url>"
    ]
  # ...
  ```
  """

  @dialyzer {:nowarn_function, http_adapter: 0}

  @behaviour BoomNotifier.Notifier

  alias BoomSlackNotifier.{SlackMessage, SlackClient}
  require Logger

  @type options :: [{:webhook_url, String.t()}]

  @impl BoomNotifier.Notifier
  def validate_config(options) do
    if Keyword.has_key?(options, :webhook_url) do
      :ok
    else
      {:error, ":webhook_url parameter is missing"}
    end
  end

  @impl BoomNotifier.Notifier
  @spec notify(BoomNotifier.ErrorInfo.t(), options) :: no_return()
  def notify(error_info, options) do
    headers = [{"Content-type", "application/json"}]

    response =
      error_info
      |> SlackMessage.create_message()
      |> Jason.encode!()
      |> http_adapter().post(options[:webhook_url], headers)

    case response do
      {:error, info} ->
        Logger.error("An error occurred when sending a notification: #{info}")

      _ ->
        nil
    end
  end

  @spec http_adapter() :: no_return()
  defp http_adapter(),
    do: Application.get_env(:boom_slack_notifier, :http_adapter, SlackClient.HTTPoisonAdapter)
end
