defmodule BoomSlackNotifierTest do
  use ExUnit.Case, async: false
  use Plug.Test
  alias Support.{TestRouter, Helpers}
  import ExUnit.CaptureLog

  @expected_message %{
    blocks: [
      # Header section
      %{
        text: %{
          emoji: true,
          text: "Boom! :boom:",
          type: "plain_text"
        },
        type: "header"
      },
      # Summary section
      %{
        text: %{
          text:
            "*Summary*\n```TestException occurred while the request was processed by TestController#index```",
          type: "mrkdwn"
        },
        type: "section"
      },
      # Request section
      %{
        fields: [
          %{
            text: "URL: ```http://www.example.com/```",
            type: "mrkdwn"
          },
          %{text: "Path: ```/```", type: "mrkdwn"},
          %{text: "Port: ```80```", type: "mrkdwn"},
          %{text: "Scheme: ```http```", type: "mrkdwn"},
          %{text: "Query String: \nN/A", type: "mrkdwn"},
          %{text: "Client IP: ```127.0.0.1```", type: "mrkdwn"}
        ],
        text: %{text: "*Request Information*", type: "mrkdwn"},
        type: "section"
      },
      # Metadata section
      %{
        fields: [
          %{
            text: "Assigns\n```age=32\nname=Davis\n```",
            type: "mrkdwn"
          },
          %{
            text: "Logger\n```age=17\nname=Dennis\n```",
            type: "mrkdwn"
          }
        ],
        text: %{text: "*Metadata*", type: "mrkdwn"},
        type: "section"
      },
      # Reason section
      %{
        text: %{
          text: "*Reason*\n```booom!```",
          type: "mrkdwn"
        },
        type: "section"
      },
      %{type: "divider"}
    ],
    text: "An exception was raised"
  }

  # The complete text and format of the stacktrace will vary depending on the elixir version, we therefore only check for the first entry
  @expected_stacktrace_entry "test/support/phoenix_app_mock.ex:10: Support.TestController.index/2"
  @success_webhook_url "http://www.someurl.com/123"

  setup do
    Process.register(self(), :test_process)
    Logger.metadata(name: "Dennis", age: 17)

    Application.put_env(:boom_slack_notifier, :test_webhook_url, value: @success_webhook_url)
  end

  test "validates return {:error, message} when url is not present" do
    assert {:error, ":webhook_url parameter is missing"} ==
             BoomSlackNotifier.SlackNotifier.validate_config(random_param: nil)
  end

  test "logs an error when the request fails" do
    Application.put_env(:boom_slack_notifier, :test_webhook_url, value: "failing_url")

    assert capture_log(fn ->
             conn = conn(:get, "/")

             catch_error(TestRouter.call(conn, TestRouter.init([])))

             Process.sleep(100)
           end) =~
             "An error occurred when sending a notification: Could not resolve URL"
  end

  test "request is sent to webhook" do
    Application.put_env(:boom_slack_notifier, :test_webhook_url, value: @success_webhook_url)

    conn = conn(:get, "/")

    catch_error(TestRouter.call(conn, TestRouter.init([])))

    assert_receive {:ok, request, url, headers}
    assert url == @success_webhook_url

    message = Jason.decode!(request, keys: :atoms)
    assert message.text == @expected_message.text
    assert headers == [{"Content-type", "application/json"}]

    [
      message_header,
      message_summary,
      message_request,
      message_metadata,
      message_stacktrace,
      message_reason,
      message_occurrences,
      _divider
    ] = message.blocks

    [accumulated_errors, first_occurrence, last_occurrence] = message_occurrences.fields

    [
      expected_header,
      expected_summary,
      expected_request,
      expected_metadata,
      expected_reason,
      _divider
    ] = @expected_message.blocks

    assert message_summary == expected_summary
    assert message_request == expected_request
    assert message_metadata == expected_metadata
    assert message_header == expected_header
    assert message_reason == expected_reason

    assert message_stacktrace.text.text =~ @expected_stacktrace_entry

    assert accumulated_errors.text =~ "Errors:"
    assert first_occurrence.text =~ "First occurrence:"
    assert last_occurrence.text =~ "Last occurrence:"

    last_occurrence_datetime = Helpers.datetime_from_text_field(last_occurrence.text)
    assert DateTime.diff(last_occurrence_datetime, DateTime.utc_now()) < 2
  end
end
