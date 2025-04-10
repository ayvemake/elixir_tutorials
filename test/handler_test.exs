defmodule HandlerTest do
  use ExUnit.Case

  import Servy.Handler, only: [handle: 1]

  test "GET /wildthings" do
    request = """
    GET /wildthings HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = handle(request)

    assert response == """
    HTTP/1.1 200 OK\r
    Content-Type: text/html\r
    Content-Length: 20\r
    \r
    Bears, Lions, Tigers
    """
  end

  test "GET /api/bears" do
    request = """
    GET /api/bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    \r
    """

    response = handle(request)

    expected_response = """
    HTTP/1.1 200 OK\r
    Content-Type: application/json\r
    Content-Length: 605\r
    \r
    [{"hibernating":true,"type":"Brown","name":"Teddy","id":1},
    {"hibernating":false,"type":"Black","name":"Smokey","id":2},
    {"hibernating":false,"type":"Brown","name":"Paddington","id":3},
    {"hibernating":true,"type":"Grizzly","name":"Scarface","id":4},
    {"hibernating":false,"type":"Polar","name":"Snow","id":5},
    {"hibernating":false,"type":"Grizzly","name":"Brutus","id":6},
    {"hibernating":true,"type":"Black","name":"Rosie","id":7},
    {"hibernating":false,"type":"Panda","name":"Roscoe","id":8},
    {"hibernating":true,"type":"Polar","name":"Iceman","id":9},
    {"hibernating":false,"type":"Grizzly","name":"Kenai","id":10}]
    """

    assert response == expected_response
  end

end
