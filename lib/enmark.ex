defmodule Enmark do
  @moduledoc false

  alias ChromeRemoteInterface.Server

  use GenStage

  @urls []

  @pages 5

  def start_link(urls \\ @urls) do
    GenStage.start_link(__MODULE__, urls, name: Enmark.UrlProducer)
  end

  def init(urls) do
    Enum.each(1..@pages, fn _ -> Enmark.Product.start_link(Server.new()) end)
    {:producer, urls}
  end

  def handle_demand(demand, urls) when demand > 0 do
    {events, urls} = Enum.split(urls, demand)
    {:noreply, events, urls}
  end
end
