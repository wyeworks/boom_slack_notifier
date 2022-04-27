defmodule Support.HttpAdapterMock do
  @behaviour BoomSlackNotifier.SlackClient.HttpAdapter

  @impl BoomSlackNotifier.SlackClient.HttpAdapter

  @spec post(any, binary, HTTPoison.Base.headers()) ::
          {:ok,
           HTTPoison.Response.t() | HTTPoison.AsyncResponse.t() | HTTPoison.MaybeRedirect.t()}
          | {:error, HTTPoison.Error.t()}
  def post(body, url, headers) do
    send(:test_process, {:ok, body, url, headers})
  end
end
