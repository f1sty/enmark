defmodule Enmark.Product do
  @moduledoc false
  @derive {Jason.Encoder, except: [:__struct__]}

  defstruct ~w/
    rating
    reviews
    title
    images_urls
    prices
  /a

  @type t :: %__MODULE__{
          rating: nil | integer,
          reviews: nil | integer,
          title: nil | binary,
          images_urls: nil | list(binary),
          prices: nil | float
        }
  @max_demand_per_page 1
  @timeout 5000

  alias ChromeRemoteInterface.{Session, PageSession}
  alias ChromeRemoteInterface.RPC.{Page, Network}
  # alias Enmark.Parser.AE, as: Parser
  # alias Enmark.Parser.Amazon, as: Parser
  alias Enmark.Parser.CB, as: Parser

  require Logger

  use GenStage

  def start_link(server) do
    GenStage.start_link(__MODULE__, server)
  end

  def init(server) do
    {:ok, ws} =
      server
      |> Session.new_page!()
      |> PageSession.start_link()

    # Enabling page events emmition and subscribing for event fired up when DOM ready to be used.
    Page.enable(ws)
    PageSession.subscribe(ws, "Page.domContentEventFired")

    {:consumer, ws, subscribe_to: [{Enmark.UrlProducer, max_demand: @max_demand_per_page}]}
  end

  def handle_events(urls, _from, ws) do
    # NOTE: using map to ease possible later use.
    _processed = Enum.map(urls, &process(&1, ws))

    {:noreply, [], ws}
  end

  # Make logger happy
  def handle_info({:chrome_remote_interface, "Page.domContentEventFired", _}, ws) do
    {:noreply, [], ws}
  end

  def process(url, ws) do
    Network.setCacheDisabled(ws, %{cacheDisabled: true})
    Page.navigate(ws, %{url: url})

    product =
      receive do
        {:chrome_remote_interface, "Page.domContentEventFired", _} ->
          Parser.parse(ws)
      after
        @timeout -> Logger.warn("#{ws} on #{url} timeouted.")
      end

    product
    |> Jason.encode!(pretty: true)
    |> IO.puts()
  end
end
