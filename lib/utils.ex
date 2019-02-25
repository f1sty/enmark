defmodule Enmark.Utils do
  alias ChromeRemoteInterface.RPC.Runtime

  def inner_text(ws, selector) do
    ws
    |> Runtime.evaluate(%{expression: "document.querySelector('#{selector}').innerText"})
    |> parse_result()
    |> String.trim()
  end

  def query(ws, query) do
    {:ok, %{"result" => result}} =
      ws
      |> Runtime.evaluate(%{expression: "document.querySelector('#{query}')"})

    result
    |> get_in(~w/result objectId/)
  end

  def query_all(ws, query) do
    {:ok, %{"result" => result}} =
      ws
      |> Runtime.evaluate(%{expression: "document.querySelectorAll('#{query}')"})

    result
    |> get_in(~w/result objectId/)
  end

  def eval(ws, expr) do
    # NOTE: reduces debug info, but sufficient for original purposes.
    ws
    |> Runtime.evaluate(%{returnByValue: true, includeCommandLineAPI: true, expression: expr})
    |> parse_result()
  end

  def parse_result(resp) do
    resp
    |> elem(1)
    |> get_in(~w/result result value/)
  end

  def to_floats_stream(string) do
    string
    |> String.split()
    |> Stream.map(&Float.parse/1)
    |> Stream.reject(&Kernel.==(&1, :error))
    |> Stream.map(fn {num, _unparsed} -> num end)
  end
end
