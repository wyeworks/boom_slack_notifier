use Mix.Config

config :boom_slack_notifier, :http_adapter, BoomSlackNotifier.SlackClient.HTTPoisonAdapter
