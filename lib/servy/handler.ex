
defmodule Servy.Handler do

  @moduledoc "Handles HTTP requests"
  alias Servy.Conv
  alias Servy.BearController



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

  def route(%Conv{ method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{ method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end


  def route(%Conv{ method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{ path: path } = conv) do
    %{ conv | resp_status: 404, resp_body: "No #{path} here!"}
  end




  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    Content-Type: text/html\r
    Content-Length: #{String.length(conv.resp_body)}\r
    \r
    #{conv.resp_body}
    """
  end
end
