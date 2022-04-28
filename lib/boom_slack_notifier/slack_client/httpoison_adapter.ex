defmodule BoomSlackNotifier.SlackClient.HTTPoisonAdapter do
  @moduledoc false

  @behaviour BoomSlackNotifier.SlackAdapter

  HTTPoison.start()

  @impl BoomSlackNotifier.SlackAdapter
  @spec post(any, binary, HTTPoison.Base.headers()) ::
          {:ok,
           HTTPoison.Response.t() | HTTPoison.AsyncResponse.t() | HTTPoison.MaybeRedirect.t()}
          | {:error, HTTPoison.Error.t()}
  def post(body, url, headers) do
    HTTPoison.post(url, body, headers, [])
  end
end
