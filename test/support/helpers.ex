defmodule Support.Helpers do
  @mock_slack_webhook_url "http://localhost:1234"
  def mock_slack_webhook_url, do: @mock_slack_webhook_url

  def datetime_from_text_field(datetime_text) do
    # Get the datetime from the field text e.g. "Last occurrence: ```2022-04-27 00:27:34.040105Z```"
    Regex.run(~r/(?<=\```)(.*?)(?=\```)/, datetime_text, capture: :first)
    |> Enum.at(0)
    |> DateTime.from_iso8601()
    |> elem(1)
  end
end
