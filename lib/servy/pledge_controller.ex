defmodule Servy.PledgeController do

  def create(conv, %{"name" => name, "amount" => amount_string}) do
    amount = String.to_integer(amount_string)

    # Créer le pledge via le PledgeServer
    id = Servy.PledgeServer.create_pledge(name, amount)

    %{ conv |
       resp_status: 201,
       resp_body: "#{name} pledged #{amount}! (id: #{id})" }
  end

  def index(conv) do
    pledges = Servy.PledgeServer.recent_pledges()
    total = Servy.PledgeServer.total_pledged()

    %{ conv |
       resp_status: 200,
       resp_body: """
       Recent Pledges:
       #{inspect pledges}

       Total pledged: #{total}
       """ }
  end
end
