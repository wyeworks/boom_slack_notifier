defmodule SlackClient.SlackAdapter do
  @moduledoc false

  @behaviour SlackClient.HttpAdapter

  HTTPoison.start()

  @impl SlackClient.HttpAdapter
  @spec post(any, binary, HTTPoison.Base.headers()) ::
          {:ok,
           HTTPoison.Response.t() | HTTPoison.AsyncResponse.t() | HTTPoison.MaybeRedirect.t()}
          | {:error, HTTPoison.Error.t()}
  def post(body, url, headers) do
    HTTPoison.post(url, body, headers, [])
  end
end
