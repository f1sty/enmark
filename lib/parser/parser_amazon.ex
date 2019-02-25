defmodule Enmark.Parser.Amazon do
  @moduledoc false

  use Enmark.Parser

  def parse(ws) do
    parse(ws,
      title: "#productTitle",
      rating: "#acrPopover",
      reviews: "#acrCustomerReviewText",
      prices: "#priceblock_ourprice",
      images_parser: """
      document.querySelectorAll('.a-button-thumbnail').forEach(el => el.click());
      let tmp = document.querySelectorAll('img[class*=a-stretch].a-dynamic-image');
      Array.from(tmp).map(el => el.src);
      """
    )
  end

  def get_images_urls(ws, expr) do
    ws
    |> eval(expr)
    |> Enum.map(&Regex.replace(~r/\._.+_\./, &1, "."))
  end

  def get_prices(ws, selector) do
    with text_price <- inner_text(ws, selector) do
      ~r/(\$|-)*/
      |> Regex.replace(text_price, "")
      |> to_floats_stream()
      |> Stream.map(&Kernel.*(&1, 100))
      |> Stream.map(&round/1)
      |> Enum.to_list()
    end
  end
end
