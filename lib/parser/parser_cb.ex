defmodule Enmark.Parser.CB do
  @moduledoc false

  use Enmark.Parser

  def parse(ws) do
    parse(ws,
      title: ".js-product-name",
      rating: ".review-rating__score-meter",
      reviews: ".review-rating__reviews",
      prices: ".sales-price__current",
      images_parser: """
      let img = document.querySelector('.product-media-gallery');
      JSON.parse(img.getAttribute('data-component'))[3].options.images.map((im) => im.image_url);
      """
    )
  end

  def get_prices(ws, selector) do
    ws
    |> inner_text(selector)
    |> String.replace("-", "00")
    |> String.replace(".", "")
    |> String.to_float()
    |> Kernel.*(100)
    |> round()
    |> List.wrap()
  end
end
