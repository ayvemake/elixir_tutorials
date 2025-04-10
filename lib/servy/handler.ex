# Le module principal qui gère les requêtes HTTP
defmodule Servy.Handler do
  # Documentation du module
  @moduledoc "Handles HTTP requests."

  # Imports et alias pour simplifier l'utilisation d'autres modules
  alias Servy.Conv                                    # Structure de données pour la conversation HTTP
  alias Servy.BearController                         # Contrôleur pour les ours
  alias Servy.Api.BearController, as: ApiBearController  # Contrôleur API pour les ours
  alias Servy.PledgeController

  # Chemin vers les pages statiques
  @pages_path Path.expand("pages", File.cwd!)

  # Import des fonctions de plugin avec restriction aux fonctions spécifiques
  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]

  # Fonction principale qui transforme une requête en réponse
  # Elle utilise le pipe operator |> pour chaîner les transformations
  def handle(request) do
    request
    |> parse           # Parse la requête
    |> rewrite_path    # Réécrit le chemin si nécessaire
    |> log            # Journalise la requête
    |> route          # Route vers le bon gestionnaire
    |> track          # Suit la requête
    |> format_response # Formate la réponse finale
  end

  # Parse la requête HTTP en structure Conv
  def parse(request) do
    [top, params_string] = String.split(request, "\r\n\r\n")

    [request_line | header_lines] = String.split(top, "\n")

    [method, path, _] = String.split(request_line, " ")

    headers = parse_headers(header_lines, %{})

    params = parse_params(headers["Content-Type"], params_string)

    %Conv{
      method: method,
      path: path,
      params: params,
      headers: headers
    }
  end

  def parse_headers([head | tail], headers) do
    [key, value] = String.split(head, ": ")
    headers = Map.put(headers, key, value)
    parse_headers(tail, headers)
  end

  def parse_headers([], headers), do: headers

  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string
    |> String.trim
    |> URI.decode_query
  end

  def parse_params(_, _), do: %{}

  # Routes pour différentes requêtes HTTP

  # Regrouper toutes les routes GET ensemble
  def route(%Conv{method: "GET", path: "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read
    |> handle_file(conv)
  end



  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{conv | resp_status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "GET", path: "/hibernate/" <> time} = conv) do
    time |> String.to_integer |> :timer.sleep
    %{conv | resp_status: 200, resp_body: "I'm back!"}
  end

  # Regrouper les routes POST
  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{method: "GET", path: "/pledges"} = conv) do
    PledgeController.index(conv)
  end

  def route(%Conv{method: "POST", path: "/pledges", params: params} = conv) do
    PledgeController.create(conv, params)
  end

  # Route par défaut en dernier
  def route(%Conv{path: path} = conv) do
    %{conv | resp_status: 404, resp_body: "No #{path} here!"}
  end

  # Gestionnaires de fichiers
  def handle_file({:ok, content}, conv) do
    # Succès : renvoie le contenu avec status 200
    %{conv | resp_status: 200, resp_body: content}
  end

  def handle_file({:error, :enoent}, conv) do
    # Fichier non trouvé : status 404
    %{conv | resp_status: 404, resp_body: "File not found"}
  end

  def handle_file({:error, reason}, conv) do
    # Autre erreur : status 500
    %{conv | resp_status: 500, resp_body: "File error: #{reason}"}
  end

  # Routes pour l'API des ours
  def route(%Conv{method: "GET", path: "/api/bears"} = conv) do
    ApiBearController.index(conv)  # Liste tous les ours via l'API
  end

  def route(%Conv{method: "GET", path: "/form"} = _conv) do
    # ... implementation ...
  end

  # Formate la réponse HTTP finale
  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    Content-Type: #{conv.resp_content_type}\r
    Content-Length: #{String.length(conv.resp_body)}\r
    \r
    #{conv.resp_body}
    """
  end
end
