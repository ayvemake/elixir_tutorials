defmodule Servy.PledgeServer do

  @name :pledge_server

  use GenServer

  defmodule State do
    defstruct cache_size: 4, pledges: []
  end

  # Client API
  def start_link(_args) do
    IO.puts "Starting the pledge server..."
    GenServer.start_link(__MODULE__, %State{}, name: @name)
  end

  def create_pledge(name, amount) do
    GenServer.call(@name, {:create_pledge, name, amount})
  end

  def recent_pledges do
    GenServer.call(@name, :recent_pledges)
  end

  def total_pledged do
    GenServer.call(@name, :total_pledged)
  end

  def clear do
    GenServer.cast(@name, :clear)
  end

  def set_cache_size(size) do
    GenServer.cast @name, {:set_cache_size, size}
  end

  # Server Callbacks
  def init(state) do
    pledges = fetch_recent_pledges_from_service()
    new_state = %{state | pledges: pledges}
    {:ok, new_state}
  end

  @impl GenServer
  def init(%State{} = state) do
    # Initialiser avec des données de test
    initial_pledges = [
      {"larry", 10},
      {"moe", 20},
      {"curly", 30},
      {"daisy", 40},
      {"grace", 50}
    ]

    # Créer les pledges initiaux
    new_state = Enum.reduce(initial_pledges, state, fn {name, amount}, acc ->
      {:ok, _id} = send_pledge_to_service(name, amount)
      most_recent_pledges = Enum.take(acc.pledges, acc.cache_size - 1)
      cached_pledges = [{name, amount} | most_recent_pledges]
      %State{acc | pledges: cached_pledges}
    end)

    {:ok, new_state}
  end

  @impl GenServer
  def handle_cast(:clear, state) do
    {:noreply, %{state | pledges: []}}
  end

  @impl GenServer
  def handle_cast({:set_cache_size, size}, state) do
    new_state = %{state | cache_size: size}
    {:noreply, new_state}
  end

  @impl GenServer
  def handle_call(:total_pledged, _from, state) do
    total = Enum.map(state.pledges, &elem(&1, 1)) |> Enum.sum
    {:reply, total, state}
  end

  @impl GenServer
  def handle_call(:recent_pledges, _from, state) do
    {:reply, state.pledges, state}
  end

  @impl GenServer
  def handle_call({:create_pledge, name, amount}, _from, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state.pledges, state.cache_size - 1)
    cached_pledges = [{name, amount} | most_recent_pledges]
    new_state = %State{state | pledges: cached_pledges}
    {:reply, id, new_state}
  end

  defp send_pledge_to_service(_name, _amount) do
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

  defp fetch_recent_pledges_from_service do
    [
      {"larrrry", 10},
      {"moe", 20},
      {"curly", 30},
    ]
  end

end
