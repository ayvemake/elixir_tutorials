defmodule PledgeServerTest do
  use ExUnit.Case

  alias Servy.PledgeServer

  setup do
    pid = PledgeServer.start()
    {:ok, pid: pid}
  end

  test "server stores pledges and returns them" do
    PledgeServer.create_pledge("larry", 10)
    PledgeServer.create_pledge("moe", 20)
    PledgeServer.create_pledge("curly", 30)

    pledges = PledgeServer.recent_pledges()
    assert length(pledges) == 3
    assert Enum.member?(pledges, {"larry", 10})

    assert PledgeServer.total_pledged() == 60
  end

  test "clear empties the pledge list" do
    PledgeServer.create_pledge("larry", 10)
    PledgeServer.clear()

    assert PledgeServer.recent_pledges() == []
    assert PledgeServer.total_pledged() == 0
  end
end
