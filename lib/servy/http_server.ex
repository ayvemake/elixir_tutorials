defmodule Servy.HttpServer do
  use GenServer  # Transforme le module en serveur générique OTP

  # Fonction de démarrage appelée par le superviseur
  def start_link(port) do
    IO.puts "Starting the HTTP server on port #{port}..."
    # Démarre le GenServer avec :
    # - ce module comme callback
    # - port comme argument initial
    # - nom enregistré comme __MODULE__
    GenServer.start_link(__MODULE__, port, name: __MODULE__)
  end

  # Callback appelé lors de l'initialisation
  def init(port) do
    Process.flag(:trap_exit, true)  # Pour gérer proprement l'arrêt
    server_pid = start_server(port)  # Démarre le vrai serveur TCP
    {:ok, server_pid}  # Retourne le PID comme état
  end

  # Démarre le serveur TCP dans un processus séparé
  def start_server(port) do
    spawn_link(fn ->
      case :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true]) do
        {:ok, listen_socket} ->
          IO.puts "\nListening for connection requests on port #{port}...\n"
          accept_loop(listen_socket)
        {:error, reason} ->
          IO.puts "\nError starting server: #{reason}\n"
      end
    end)
  end

  # Gère les messages de fin de processus
  def handle_info({:EXIT, _pid, reason}, _state) do
    IO.puts "HttpServer process exited: #{inspect reason}"
    {:stop, reason, nil}
  end

  # Boucle d'acceptation des connexions
  defp accept_loop(listen_socket) do
    {:ok, client_socket} = :gen_tcp.accept(listen_socket)  # Attend une connexion
    spawn(fn -> serve(client_socket) end)  # Traite la connexion dans un nouveau processus
    accept_loop(listen_socket)  # Continue d'accepter des connexions
  end

  # Traite une connexion client
  defp serve(client_socket) do
    client_socket
    |> read_request      # 1. Lit la requête HTTP
    |> Servy.Handler.handle  # 2. Traite la requête
    |> write_response(client_socket)  # 3. Envoie la réponse
  end

  # Fonctions auxiliaires pour la lecture/écriture sur le socket
  def read_request(client_socket) do
    {:ok, request} = :gen_tcp.recv(client_socket, 0)
    request
  end

  def write_response(response, client_socket) do
    :ok = :gen_tcp.send(client_socket, response)
    :gen_tcp.close(client_socket)
  end
end
