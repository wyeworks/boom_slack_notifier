defmodule Support.HttpAdapterMock do
  @behaviour BoomSlackNotifier.SlackClient.HttpAdapter

  @impl BoomSlackNotifier.SlackClient.HttpAdapter

  @spec post(any, binary, any) :: {:ok, any} | {:error, any}
  def post(_body, "failing_url", _headers) do
    {:error, "Could not resolve URL"}
  end

  def post(body, url, headers) do
    send(:test_process, {:ok, body, url, headers})
  end
end
