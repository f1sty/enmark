defmodule Enmark.Parser.Ebay do
  @moduledoc false

  use Enmark.Parser

  def parse(ws) do
    parse(ws,
      title: "#itemTitle",
      prices: "#prcIsum",
      images_parser: "$$('a[id*=viEnlargeImgLayer].pic.pic1 table.img img').map(el => el.src)"
    )
  end

  def get_images_urls(ws, expr) do
    ws
    |> eval(expr)
    |> Enum.map(&Regex.replace(~r/64.jpg$/, &1, "1600.jpg"))
  end
end
