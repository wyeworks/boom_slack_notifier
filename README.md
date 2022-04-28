# BoomSlackNotifier

Provides a slack notifier for the [BoomNotifier](https://github.com/wyeworks/boom) exception notification package.

You can read the full documentation at [https://hexdocs.pm/boom_slack_notifier](https://hexdocs.pm/boom_slack_notifier).

## Installation

The package can be installed by adding `boom_slack_notifier` to your list of dependencies in
`mix.exs`:

```elixir
def deps do
  [
    {:boom_notifier, "~> 0.8.0"},
    {:boom_slack_notifier, "~> 0.1.0"}
  ]
end
```

## How to use it

```elixir
defmodule YourApp.Router do
  use Phoenix.Router

  use BoomNotifier,
    notifier: BoomSlackNotifier.SlackNotifier,
    options: [
      webhook_url: "<your-slack-generated-url>",
    ]

  # ...
```

To configure it, you need to set the `webhook_url` in the `options` keyword list. A `POST` request with a `json` will be made to that webhook when an error ocurrs with the relevant information.

If you don't already have a webhook setup for slack, you can follow the steps below:

1. Go to [Slack API](https://api.slack.com/) > My Apps
2. Create a new application
3. Inside your new application go to > Add features and functionality > Incoming Webhooks
4. Activate incoming webhooks for your application
5. Scroll down to 'Webhook URLs for Your Workspace' and create a new Webhook URL for a given channel.

## Http client

By default BoomSlackNotifier uses [HTTPoison](https://github.com/edgurgel/httpoison) as the http client. 

You can setup your favorite client by warpping it with the `SlackClient.HttpAdapter` behaviour, for example:

```
#mojito_http_adapter.ex

  @impl BoomSlackNotifier.SlackClient.HttpAdapter
  @spec post(any, binary, any) :: {:ok, any} | {:error, any}
  def post(body, url, headers) do
    {:ok, response} = Mojito.request(body: body, method: :post, url: url, headers: headers)
    # ...
  end
```

And then specifying it in your application configuration:

```
#config.exs

config :boom_slack_notifier, :http_adapter, MyApp.MojitoHttpAdapter

```

Default configuration (not required): 
```
config :boom_slack_notifier, :http_adapter, BoomSlackNotifier.SlackClient.HTTPoisonAdapter
```
## License

BoomSlackNotifier is released under the terms of the [MIT License](https://github.com/wyeworks/boom/blob/master/LICENSE).
