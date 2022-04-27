defmodule BoomSlackNotifier.SlackClient.HttpAdapter do
  @moduledoc false

  @doc """
  Defines a callback to be used by the http adapters
  """
  @callback post(any, binary, HTTPoison.Base.headers()) ::
              {:ok,
               HTTPoison.Response.t() | HTTPoison.AsyncResponse.t() | HTTPoison.MaybeRedirect.t()}
              | {:error, HTTPoison.Error.t()}
end
