defmodule Enmark.Runner do
  alias ChromeRemoteInterface.Server

  use Supervisor

  @urls []

  @pages 10

  def start_link(urls \\ @urls) do
    Supervisor.start_link(__MODULE__, urls, name: __MODULE__)
  end

  @impl true
  def init(urls) do
    server = Server.new()

    workers =
      Enum.map(1..@pages, fn num ->
        Supervisor.child_spec({Enmark.Product, server}, id: Module.concat(Page, "#{num}"))
      end)

    children = [{Enmark, urls}] ++ workers

    Supervisor.init(children, strategy: :one_for_one)
  end
end
