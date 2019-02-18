defmodule Enmark.Utils do

  alias ChromeRemoteInterface.RPC.Runtime

  def inner_text(oid, ws) do
    oid
    |> call_js_func(ws, "el => el.innerText")
    |> get_in(~w/result value/)
    |> String.trim()
  end

  def call_js_func(oid, ws, func_declaretion) do
    {:ok, %{"result" => result}} =
      Runtime.callFunctionOn(ws, %{
        functionDeclaration: func_declaretion,
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
    |> get_in(~w/result objectId/)
  end

  def query_all(ws, query) do
    {:ok, %{"result" => result}} =
      ws
      |> Runtime.evaluate(%{expression: "document.querySelectorAll('#{query}')"})

    result
    |> get_in(~w/result objectId/)
  end

end
