defmodule Support.Helpers do
  @test_process_name :test_process
  def datetime_from_text_field(datetime_text) do
    # Get the datetime from the field text e.g. "Last occurrence: ```2022-04-27 00:27:34.040105Z```"
    Regex.run(~r/(?<=\```)(.*?)(?=\```)/, datetime_text, capture: :first)
    |> Enum.at(0)
    |> DateTime.from_iso8601()
    |> elem(1)
  end

  def register_test_process() do
    Process.register(self(), @test_process_name)
  end

  def get_test_process_name() do
    @test_process_name
  end
end
