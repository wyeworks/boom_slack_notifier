defmodule BoomSlackNotifier.SlackAdapter do
  @moduledoc """

  By default BoomSlackNotifier uses [HTTPoison](https://github.com/edgurgel/httpoison) as the http client.

  You can setup your favorite client by warpping it with the `HttpAdapter` behaviour, for example:

  ```
  #mojito_http_adapter.ex

  @impl BoomSlackNotifier.SlackAdapter
  @spec post(any, binary, any) :: {:ok, any} | {:error, any}
  def post(body, url, headers) do
    {:ok, response} = Mojito.request(body: body, method: :post, url: url, headers: headers)
    # ...
  end
  ```

  And then specifying it in your application configuration:

  ```
  #config.exs

  config :boom_slack_notifier, :slack_adapter, MyApp.MojitoHttpAdapter

  ```

  Default configuration (not required):
  ```
  config :boom_slack_notifier, :slack_adapter, BoomSlackNotifier.SlackClient.HTTPoisonAdapter
  ```
  """

  @doc """
  Defines a callback to be used by the http adapters
  """
  @callback post(any, binary, any) :: {:ok, any} | {:error, any}
end
