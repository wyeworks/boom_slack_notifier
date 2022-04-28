defmodule Support.HttpAdapterMock do
  @behaviour BoomSlackNotifier.SlackClient.HttpAdapter
  alias Support.Helpers

  @impl BoomSlackNotifier.SlackClient.HttpAdapter

  @spec post(any, binary, any) :: {:ok, any} | {:error, any}
  def post(_body, "failing_url", _headers) do
    {:error, "Could not resolve URL"}
  end

  def post(body, url, headers) do
    send(Helpers.get_test_process_name(), {:ok, body, url, headers})
  end
end
