defmodule Enmark.Product do
  @derive {Jason.Encoder, except: [:__struct__]}

  defstruct rating: 0,
            reviews: 0,
            title: "",
            images_urls: [],
            price: 0

  @max_demand_per_page 1
  @timeout 5000

  alias ChromeRemoteInterface.{Session, PageSession}
  alias ChromeRemoteInterface.RPC.Page
  alias Enmark.Parser.CB, as: Parser
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
    Enum.map(urls, &process(&1, ws))

    {:noreply, [], ws}
  end

  # Make logger happy
  def handle_info({:chrome_remote_interface, "Page.domContentEventFired", _}, ws) do
    {:noreply, [], ws}
  end

  def process(url, ws) do
    Page.navigate(ws, %{url: url})

    product =
      receive do
        {:chrome_remote_interface, "Page.domContentEventFired", _} ->
          Parser.parse(ws)
      after
        @timeout -> IO.inspect("#{ws} on #{url} timeouted!")
      end

    product
    |> Jason.encode!()
    |> IO.puts()
  end
end
