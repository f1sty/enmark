defmodule Enmark.Parser.AE do
  @moduledoc false

  use Enmark.Parser

  def parse(ws) do
    parse(ws,
      title: ".product-name",
      rating: ".percent-num",
      reviews: ".rantings-num",
      prices: "#j-sku-discount-price.p-price",
      images_parser: "$$('.img-thumb-item img').map(el => el.src)"
    )
  end

  def get_images_urls(ws, expr) do
    ws
    |> eval(expr)
    |> Enum.map(&Regex.replace(~r/_\d{2}x\d{2}.*$/, &1, ""))
  end

  def get_rating(ws, selector) do
    ws
    |> inner_text(selector)
    |> to_floats_stream()
    |> Enum.map(fn num -> num / 5 * 100 end)
    |> hd()
    |> round()
  end
end
