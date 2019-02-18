defmodule Enmark.Parser.CB do
  alias ChromeRemoteInterface.RPC.Runtime
  alias Enmark.Product

  def parse(ws) do
    with title_oid <- query(ws, ".js-product-name"),
         reviews_oid <- query(ws, ".review-rating__reviews"),
         rating_oid <- query(ws, ".review-rating__score-meter"),
         price_oid <- query(ws, ".sales-price__current"),
         images_urls_oid <- query(ws, ".product-media-gallery") do
      %Product{
        title: inner_text(ws, title_oid),
        rating: inner_text(ws, rating_oid),
        reviews: inner_text(ws, reviews_oid),
        price: inner_text(ws, price_oid),
        images_urls: get_images_urls(ws, images_urls_oid)
      }
    end
  end

  def inner_text(ws, oid) do
    ws
    |> call_js_func(oid, "el => el.innerText")
    |> get_in(~w/result value/)
    |> String.trim()
  end

  def get_images_urls(ws, oid) do
    ws
    |> call_js_func(oid, "el => JSON.parse(el.getAttribute('data-component'))[3].options.images.map((im) => im.image_url).toString()")
    |> get_in(~w/result value/)
  end

  def call_js_func(ws, oid, func_declaretion) do
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
