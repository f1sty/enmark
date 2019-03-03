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
      $$('.a-button-thumbnail').forEach(el => el.click());
      $$('img[class*=a-stretch].a-dynamic-image').map(el => el.src);
      """
    )
  end

  def get_images_urls(ws, expr) do
    ws
    |> eval(expr)
    |> Enum.map(&Regex.replace(~r/\._.+_\./, &1, "."))
  end
end
