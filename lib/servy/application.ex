defmodule Servy.Application do
  use Application  # Indique que ce module est une application OTP

  @impl true  # Indique que cette fonction implémente un callback OTP
  def start(_type, _args) do
    # Liste des processus enfants à démarrer et superviser
    children = [
      Servy.PledgeServer,  # Serveur de gestion des promesses
      {Servy.HttpServer, 4000}  # Serveur HTTP sur le port 4000
    ]

    # Configuration du superviseur :
    # - strategy: :one_for_one -> si un enfant meurt, seul celui-ci est redémarré
    # - name: nom du superviseur pour pouvoir y faire référence
    opts = [strategy: :one_for_one, name: Servy.Supervisor]

    # Démarrer le superviseur
    result = Supervisor.start_link(children, opts)

    # Configurer le PledgeServer après son démarrage
    Servy.PledgeServer.set_cache_size(4)

    # Retourner le résultat du superviseur
    result
  end
end
