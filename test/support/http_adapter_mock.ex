defmodule Support.HttpAdapterMock do
  @behaviour BoomSlackNotifier.SlackAdapter
  alias Support.Helpers

  @impl BoomSlackNotifier.SlackAdapter

  @spec post(any, binary, any) :: {:ok, any} | {:error, any}
  def post(_body, "failing_url", _headers) do
    {:error, %{reason: "Could not resolve URL"}}
  end

  def post(body, url, headers) do
    send(Helpers.get_test_process_name(), {:ok, body, url, headers})
  end
end
