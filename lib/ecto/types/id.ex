if Code.ensure_loaded?(Ecto.ParameterizedType) do
  defmodule Shortcode.Ecto.ID do
    use Ecto.ParameterizedType

    @spec init(keyword) :: map
    def init(opts) do
      validate_opts!(opts)

      Enum.into(opts, %{})
    end

    @spec type(any) :: :id
    def type(_), do: :id

    @spec cast(binary, map) :: {:ok, integer}
    def cast(integer, _) when is_integer(integer) and integer >= 0, do: {:ok, integer}

    def cast(shortcode, _) when is_binary(shortcode) and byte_size(shortcode) > 0 do
      {:ok, Shortcode.to_integer(shortcode)}
    end

    def cast(_, _), do: :error

    @spec load(integer, any, map) :: {:ok, binary}
    def load(integer, _, params) when is_integer(integer) and integer >= 0 do
      prefix = Map.get(params, :prefix)

      {:ok, Shortcode.to_shortcode(integer, prefix)}
    end

    def load(_, _, _), do: :error

    @spec dump(any, any, map) :: {:ok, integer} | :error
    def dump(value, _dumper, params), do: cast(value, params)

    defp validate_opts!(opts) do
      prefix = opts |> Keyword.get(:prefix)

      if not is_nil(prefix) and String.contains?(prefix, Shortcode.prefix_separator()) do
        raise ArgumentError, "prefix cannot contain \"#{Shortcode.prefix_separator()}\""
      end
    end
  end
end
