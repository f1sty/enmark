defmodule Enmark.Parser do
  @callback parse(websocket :: pid()) :: Enmark.Product.t()
end
