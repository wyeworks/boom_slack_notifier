defmodule Support.HttpAdapterMock do
  @behaviour SlackClient.HttpAdapter

  @impl SlackClient.HttpAdapter

  @spec post(any, binary, HTTPoison.Base.headers()) ::
          {:ok,
           HTTPoison.Response.t() | HTTPoison.AsyncResponse.t() | HTTPoison.MaybeRedirect.t()}
          | {:error, HTTPoison.Error.t()}
  def post(body, url, headers) do
    send(:test_process, {:ok, body, url, headers})
  end
end
