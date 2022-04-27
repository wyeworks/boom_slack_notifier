defmodule BoomSlackNotifier.SlackNotifier do
  @moduledoc """
  Send exception notifications as slack messages using `HTTPoison`.

  ## Usage
  ```elixir
  defmodule YourApp.Router do
  use Phoenix.Router

  use BoomNotifier,
    notifier: BoomSlackNotifier.SlackNotifier,
    options: [
      slack_webhook_url: "<your-slack-generated-url>"
    ]
  # ...
  ```
  """

  @dialyzer {:nowarn_function, http_adapter: 0}

  @behaviour BoomNotifier.Notifier

  alias BoomSlackNotifier.SlackMessage

  @type options :: [{:slack_webhook_url, String.t()}]

  @impl BoomNotifier.Notifier
  def validate_config(options) do
    if Keyword.has_key?(options, :slack_webhook_url) do
      :ok
    else
      {:error, ":slack_webhook_url parameter is missing"}
    end
  end

  @impl BoomNotifier.Notifier
  @spec notify(BoomNotifier.ErrorInfo.t(), options) :: no_return()
  def notify(error_info, options) do
    headers = [{"Content-type", "application/json"}]

    error_info
    |> SlackMessage.create_message()
    |> Jason.encode!()
    |> http_adapter().post(options[:slack_webhook_url], headers)
  end

  @spec http_adapter() :: no_return()
  defp http_adapter() do
    Application.get_env(:boom_slack_notifier, :http_adapter, SlackClient.SlackAdapter)
  end
end
