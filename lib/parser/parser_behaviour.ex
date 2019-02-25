defmodule Enmark.ParserBehaviour do
  @callback parse(websocket :: pid(), options :: keyword()) :: Enmark.Product.t()
  @callback get_title(websocket :: pid(), selector :: binary()) :: binary()
  @callback get_rating(websocket :: pid(), selector :: binary()) :: integer()
  @callback get_reviews(websocket :: pid(), selector :: binary()) :: integer()
  @callback get_prices(websocket :: pid(), selector :: binary()) :: list(float())
  @callback get_images_urls(websocket :: pid(), images_parse_js_func :: binary()) ::
              list(binary())
end
