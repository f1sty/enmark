defmodule Enmark.Parser.CB do
  @moduledoc false
  @behaviour Enmark.Parser

  alias Enmark.Product

  import Enmark.Utils

  @impl true
  def parse(ws) do
    %Product{
      title: get_title(ws),
      rating: get_rating(ws),
      reviews: get_reviews(ws),
      price: get_price(ws),
      images_urls: get_images_urls(ws)
    }
  end

  def get_title(ws) do
    ws
    |> query(".js-product-name")
    |> inner_text(ws)
  end

  def get_rating(ws) do
    ws
    |> query(".review-rating__score-meter")
    |> inner_text(ws)
  end

  def get_reviews(ws) do
    ws
    |> query(".review-rating__reviews")
    |> inner_text(ws)
    |> String.split()
    |> hd()
    |> String.to_integer()
  end

  def get_price(ws) do
    ws
    |> query(".sales-price__current")
    |> inner_text(ws)
    |> String.replace("-", "00")
    |> String.replace(".", "")
    |> String.to_float()
    |> Kernel.*(100)
    |> Float.round(2)
  end

  def get_images_urls(ws) do
    ws
    |> query(".product-media-gallery")
    |> call_js_func(
      ws,
      "el => JSON.parse(el.getAttribute('data-component'))[3].options.images.map((im) => im.image_url).toString()"
    )
    |> get_in(~w/result value/)
    |> String.split(",")
  end

end
