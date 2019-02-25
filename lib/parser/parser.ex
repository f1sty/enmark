defmodule Enmark.Parser do
  defmacro __using__(_opts) do
    quote do
      @behaviour Enmark.ParserBehaviour

      alias Enmark.Product

      import Enmark.Utils

      def parse(ws, args) do
        # NOTE: keyword options here imply selectors for corresponding fields in %Enmark.Product{}.
        # Also none of these options are required. In default implementation sets matching field in
        # %Enmark.Product{} to nil, if one ommited.
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
        with text_reviews <- inner_text(ws, selector) do
          ~r/\D*/
          |> Regex.replace(text_reviews, "")
          |> String.to_integer()
        end
      end

      def get_prices(ws, selector) do
        with text_price <- inner_text(ws, selector) |> String.replace(",", ".") do
          ~r/(\p{Pd}|\p{Sc})*/
          |> Regex.replace(text_price, "")
          |> to_floats_stream()
          |> Stream.map(&Kernel.*(&1, 100))
          |> Stream.map(&round/1)
          |> Enum.to_list()
        end
      end

      def get_images_urls(ws, expr), do: eval(ws, expr)

      defoverridable Enmark.ParserBehaviour
    end
  end
end
