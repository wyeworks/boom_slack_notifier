defmodule BoomSlackNotifier.SlackMessage do
  import BoomNotifier.Helpers

  @moduledoc false

  @spec create_message(BoomNotifier.ErrorInfo.t()) :: no_return()
  def create_message(error) do
    error
    |> Map.from_struct()
    |> format_summary()
    |> format_stacktrace()
    |> create_section_blocks()
    |> create_message_body()
  end

  defp format_summary(
         %{
           controller: controller,
           action: action
         } = error
       )
       when is_nil(controller) or is_nil(action) do
    error
  end

  defp format_summary(
         %{
           name: name,
           controller: controller,
           action: action
         } = error
       ) do
    Map.put(
      error,
      :exception_summary,
      exception_basic_text(name, controller, action)
    )
  end

  defp format_stacktrace(error) do
    %{error | stack: Enum.map(error.stack, &Exception.format_stacktrace_entry/1)}
  end

  defp create_section_blocks(error) do
    # Sections are prepended to the list, the slack message will display them in reverse order
    [%{type: "divider"}]
    |> add_occurrences_section(error[:occurrences])
    |> add_reason_section(error[:reason])
    |> add_stacktrace_section(error[:stack])
    |> add_metadata_section(error[:metadata])
    |> add_request_section(error[:request])
    |> add_summary_section(error[:exception_summary])
  end

  defp add_occurrences_section(sections_list, nil) do
    sections_list
  end

  defp add_occurrences_section(sections_list, occurrences) do
    occurrences_section = %{
      type: "section",
      text: %{
        type: "mrkdwn",
        text: "*Occurrences*"
      },
      fields: [
        request_field("Errors", occurrences.accumulated_occurrences),
        request_field("First occurrence", occurrences.first_occurrence),
        request_field("Last occurrence", occurrences.last_occurrence)
      ]
    }

    [occurrences_section | sections_list]
  end

  defp add_reason_section(sections_list, nil) do
    # ErrorInfo didn't include reason
    sections_list
  end

  defp add_reason_section(sections_list, reason) do
    [plain_text_section("Reason", reason) | sections_list]
  end

  defp add_stacktrace_section(sections_list, nil) do
    # ErrorInfo didn't include stacktrace
    sections_list
  end

  defp add_stacktrace_section(sections_list, stack_entries) do
    stacktrace = Enum.reduce(stack_entries, "", fn entry, acc -> "#{acc}\n#{entry}" end)

    stacktrace_section = %{
      type: "section",
      text: %{
        type: "mrkdwn",
        text: "*Stacktrace*\n```#{stacktrace}```"
      }
    }

    [stacktrace_section | sections_list]
  end

  defp add_metadata_section(sections_list, nil) do
    # ErrorInfo didn't include metadata
    sections_list
  end

  defp add_metadata_section(sections_list, metadata) when metadata == %{} do
    sections_list
  end

  defp add_metadata_section(sections_list, metadata) do
    metadata_section = %{
      type: "section",
      text: %{
        type: "mrkdwn",
        text: "*Metadata*"
      },
      fields: Enum.map(metadata, fn {key, value} -> metadata_field(key, value) end)
    }

    [metadata_section | sections_list]
  end

  defp metadata_field(label, content) when content == %{} do
    %{
      type: "mrkdwn",
      text: "#{label}:\n N/A"
    }
  end

  defp metadata_field(label, content) do
    # Each field of the metadata section contains a codeblock with the key-value pairs
    content =
      Enum.reduce(content, "", fn {key, value}, acc ->
        acc <> "#{key}=#{value || "N/A"}\n"
      end)

    label = String.capitalize("#{label}")

    %{
      type: "mrkdwn",
      text: "#{label}\n```#{content}```"
    }
  end

  defp add_request_section(sections_list, nil) do
    # ErrorInfo didn't include request
    sections_list
  end

  defp add_request_section(sections_list, request) do
    request_section = %{
      type: "section",
      text: %{
        type: "mrkdwn",
        text: "*Request Information*"
      },
      fields: [
        request_field("URL", request[:url]),
        request_field("Path", request[:path]),
        request_field("Port", request[:port]),
        request_field("Scheme", request[:scheme]),
        request_field("Query String", request[:query_string]),
        request_field("Client IP", request[:client_ip])
      ]
    }

    [request_section | sections_list]
  end

  defp request_field(label, content) do
    %{
      type: "mrkdwn",
      text: field_text(label, content)
    }
  end

  defp add_summary_section(sections_list, nil) do
    # ErrorInfo didn't include summary
    sections_list
  end

  defp add_summary_section(sections_list, summary) do
    [plain_text_section("Summary", summary) | sections_list]
  end

  defp field_text(label, content) do
    content = if content === "", do: "\nN/A", else: "```#{content}```"
    "#{label}: #{content}"
  end

  defp plain_text_section(header, text) do
    %{
      type: "section",
      text: %{
        type: "mrkdwn",
        text: "*#{header}*\n```#{text}```"
      }
    }
  end

  defp create_message_body(error_blocks) do
    message_header = %{
      type: "header",
      text: %{
        type: "plain_text",
        text: "Boom! :boom:",
        emoji: true
      }
    }

    %{
      text: "An exception was raised",
      blocks: [message_header | error_blocks]
    }
  end
end
