defmodule ParserTest do
  use ExUnit.Case
  alias Servy.Parser

  test "parses a list of header fields into a map" do
    header_lines = ["A: 1", "B: 2"]
    headers = Parser.parse_headers(header_lines, %{})
    assert headers == %{"A" => "1", "B" => "2"}
  end

  test "parses a POST request" do
    request = """
    POST /bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    Content-Type: application/x-www-form-urlencoded\r
    Content-Length: 21\r
    \r
    name=Baloo&type=Brown
    """

    conv = Parser.parse(request)

    assert conv.method == "POST"
    assert conv.path == "/bears"
    assert conv.params == %{"name" => "Baloo", "type" => "Brown"}
  end
end
