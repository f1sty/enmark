defmodule Enmark do
  alias ChromeRemoteInterface.{Server, Session, PageSession}
  alias ChromeRemoteInterface.RPC.{Runtime, Page}
  alias Enmark.Tasks

  @urls []

  def test() do
    @urls
    |> Enum.shuffle()
    |> Enum.take(5)
    |> batch()
  end

  def batch(urls \\ @urls) do
    server = Server.new()

    Task.Supervisor.async_stream(Tasks, urls, __MODULE__, :navigate, [server])
    |> Enum.to_list()
  end

  def navigate(url, server) do
    {:ok, ws} = server |> Session.new_page!() |> PageSession.start_link()
    Page.enable(ws)
    PageSession.subscribe(ws, "Page.domContentEventFired")
    Page.navigate(ws, %{url: url})

    %{"result" => %{"objectId" => oid}} =
      receive do
        {:chrome_remote_interface, "Page.domContentEventFired", _} ->
          query(ws, ".js-product-name")
      after
        5000 -> IO.inspect("timeout")
      end

    inner_text(ws, oid)
  end

  def inner_text(ws, oid) do
    {:ok, %{"result" => result}} =
      Runtime.callFunctionOn(ws, %{
        functionDeclaration: "function (elem) { return elem.innerText; }",
        objectId: oid,
        arguments: [%{objectId: oid}]
      })

    result
  end

  def query(ws, query) do
    {:ok, %{"result" => result}} =
      ws
      |> Runtime.evaluate(%{expression: "document.querySelector('#{query}')"})

    result
  end

  def query_all(ws, query) do
    {:ok, %{"result" => result}} =
      ws
      |> Runtime.evaluate(%{expression: "document.querySelectorAll('#{query}')"})

    result
  end
end
