defmodule BoomSlackNotifier.SlackClient.HttpAdapter do
  @moduledoc """

  Defines a behaviour for http requests

  By default BoomSlackNotifier uses [HTTPoison](https://github.com/edgurgel/httpoison) as the http client.

  You can setup your favorite client by implenting the `SlackClient.HttpAdapter` behaviour around it, for example:

  ```
  #mint_http_adapter.ex

  @impl BoomSlackNotifier.SlackClient.HttpAdapter
  @spec post(any, binary, any) :: {:ok, any} | {:error, any}
  def post(body, url, headers) do
    {:ok, response} = Mojito.request(body: body, method: :post, url: url, headers: headers)
    ...
  end
  ```

  And then specifying it in your application configuration:

  ```
  #config.exs

  config :boom_slack_notifier, :http_adapter, MyApp.SomeHttpAdapter

  ```
  """

  @doc """
  Defines a callback to be used by the http adapters
  """
  @callback post(any, binary, any) :: {:ok, any} | {:error, any}
end
