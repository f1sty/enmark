defmodule Enmark do
  @moduledoc false

  use GenStage

  def start_link(urls) do
    GenStage.start_link(__MODULE__, urls, name: Enmark.UrlProducer)
  end

  def init(urls) do
    {:producer, urls}
  end

  def handle_demand(demand, urls) when demand > 0 do
    {events, urls} = Enum.split(urls, demand)
    {:noreply, events, urls}
  end
end
