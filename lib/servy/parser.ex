defmodule Servy.Parser do

  alias Servy.Conv

  def parse(request) do
    [request_line | header_lines] =
      request
      |> String.split("\r\n")
      |> Enum.filter(&(&1 != ""))

    [method, path, _] = String.split(request_line)

    headers = parse_headers(header_lines, %{})
    params = parse_params(headers["Content-Type"], request)

    %Conv{
      method: method,
      path: path,
      params: params,
      headers: headers
    }
  end


  def parse_headers([head | tail], headers) do
    case String.split(head, ": ") do
      [key, value] ->
        headers = Map.put(headers, key, value)
        parse_headers(tail, headers)
      _ ->
        parse_headers(tail, headers)
    end
  end

  def parse_headers([], headers), do: headers

  def parse_params("application/x-www-form-urlencoded", request) do
    [_, params_string] = String.split(request, "\r\n\r\n")
    params_string |> String.trim() |> URI.decode_query()
  end

  def parse_params(_, _), do: %{}

end
