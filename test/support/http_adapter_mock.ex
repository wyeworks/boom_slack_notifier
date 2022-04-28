defmodule Support.HttpAdapterMock do
  @behaviour BoomSlackNotifier.SlackClient.HttpAdapter

  @impl BoomSlackNotifier.SlackClient.HttpAdapter

  @spec post(any, binary, any) :: no_return()
  def post(body, url, headers) do
    send(:test_process, {:ok, body, url, headers})
  end
end
