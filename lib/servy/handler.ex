
defmodule Servy.Handler do

  @moduledoc "Handles HTTP requests"
  alias Servy.Conv
  @pages_path Path.expand("pages", File.cwd!)


  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser

  @doc "Transforms the request into a response"

  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> format_response

  end






  @doc "Routes GET requests"
  def route(%Conv{ method: "GET", path: "/about"} = conv) do
      Path.expand("../../pages", __DIR__)
      |> Path.join("about.html")
      |> File.read
      |> handle_file(conv)
  end

  def route(%Conv{ method: "GET", path: "/form"} = conv) do
    Path.expand("../../pages", __DIR__)
    |> Path.join("form.html")
    |> File.read
    |> handle_file(conv)
end

  def handle_file({:ok, content}, conv) do
    %{ conv | resp_status: 200, resp_body: content}
  end

  def handle_file({:error, :enoent}, conv) do
    %{ conv | resp_status: 404, resp_body: "File not found"}
  end

  def handle_file({:error, reason}, conv) do
    %{ conv | resp_status: 500, resp_body: "File error: #{reason}"}
  end


#    case File.read(file) do
#      {:ok, content} ->

#      {:error, :enoent}->
#        %{ conv | resp_status: 404, resp_body: "File not found"}
#      {:error, reason} ->
#        %{ conv | resp_status: 404, resp_body: "File error: #{reason}"}
#    end



  def route(%Conv{ method: "GET", path: "/wildthings"} = conv) do
    %{ conv | resp_status: 200, resp_body: "Bears, Lions, Tigers" }
  end

  # name=Baloo&type=brown
  def route(%Conv{ method: "POST", path: "/bears"} = conv) do
    %{ conv | resp_status: 201,
              resp_body: "Created bear #{conv.params["name"]}, named #{conv.params["type"]}" }
  end

  def route(%Conv{ method: "GET", path: "/bears"} = conv) do
    %{ conv | resp_status: 200, resp_body: "Teddy, etc. are not wild" }
  end

  def route(%Conv{ method: "GET", path: "/bears/" <> id} = conv) do
    %{ conv | resp_status: 200, resp_body: "Bear #{id}"}
  end



  def route(%Conv{ path: path } = conv) do
    %{ conv | resp_status: 404, resp_body: "No #{path} here!"}
  end




  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Length: #{String.length(conv.resp_body)}

    #{conv.resp_body}
    """
  end
end

request = """
POST /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: application/x-www-form-urlencoded
Content-Length: 21

name=Baloo&type=brown
"""


response = Servy.Handler.handle(request)

IO.puts response
