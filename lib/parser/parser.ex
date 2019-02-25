defmodule Enmark.Parser do
  defmacro __using__(_opts) do
    quote do
      @behaviour Enmark.ParserBehaviour

      alias Enmark.Product

      import Enmark.Utils

      def parse(ws, args) do
        %Product{
          title: get_title(ws, args[:title]),
          rating: get_rating(ws, args[:rating]),
          reviews: get_reviews(ws, args[:reviews]),
          prices: get_prices(ws, args[:prices]),
          images_urls: get_images_urls(ws, args[:images_parser])
        }
      end

      def get_title(ws, nil), do: nil
      def get_rating(ws, nil), do: nil
      def get_reviews(ws, nil), do: nil
      def get_prices(ws, nil), do: nil
      def get_images_urls(ws, nil), do: nil

      def get_title(ws, selector), do: inner_text(ws, selector)

      def get_rating(ws, selector) do
        ws
        |> inner_text(selector)
        |> to_floats_stream()
        |> Enum.min_max()
        |> Tuple.to_list()
        |> Enum.reduce(&(&2 / &1))
        |> Kernel.*(100)
        |> round()
      end

      def get_reviews(ws, selector) do
        ws
        |> inner_text(selector)
        |> String.split()
        |> hd()
        |> String.to_integer()
      end

      def get_prices(ws, selector) do
        ws
        |> inner_text(selector)
        |> List.wrap()
      end

      def get_images_urls(ws, expr), do: eval(ws, expr)

      defoverridable Enmark.ParserBehaviour
    end
  end
end
