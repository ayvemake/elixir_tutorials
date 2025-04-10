defmodule Servy.GenericServer do

  def start(callback_module, initial_state, name) do
    case Process.whereis(name) do
      nil ->
        IO.puts "Starting the pledge server..."
        pid = spawn(__MODULE__, :listen_loop, [initial_state, callback_module])
        Process.register(pid, name)
        pid
      pid ->
        IO.puts "Pledge server is already running..."
        pid
    end
  end


  def call(pid, message) do
    send pid, {:call,self(), message}

    receive do {:response, response} -> response end
  end

  def cast(pid, message) do
    send pid, {:cast, message}
  end

  def listen_loop(state, callback_module) do
    receive do
      {:stop, reason} ->
        IO.puts "Stopping server: #{reason}"
        :ok

      {:call, sender, message} ->  # <- Correction ici
        {response, new_state} = callback_module.handle_call(message, state)
        send sender, {:response, response}
        listen_loop(new_state, callback_module)

      {:cast, message} ->  # <- Et ici
        new_state = callback_module.handle_cast(message, state)
        listen_loop(new_state, callback_module)

      unexpected ->
        IO.puts "Unexpected message: #{inspect unexpected}"
        listen_loop(state, callback_module)
    end
  end


end



defmodule Servy.PledgeServerHandRolled do
  use GenServer  # Ceci ajoute automatiquement child_spec/1

  @name :pledge_server_hand_rolled

  # Client API
  def start_link(_args) do
    IO.puts "Starting the pledge server..."
    GenServer.start_link(__MODULE__, [], name: @name)
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

  # Server Callbacks
  @impl GenServer
  def init(state) do
    {:ok, state}
  end

  @impl GenServer
  def handle_cast(:clear, _state) do
    {:noreply, []}
  end

  @impl GenServer
  def handle_call(:total_pledged, _from, state) do
    total = Enum.map(state, &elem(&1, 1)) |> Enum.sum
    {:reply, total, state}
  end

  @impl GenServer
  def handle_call(:recent_pledges, _from, state) do
    {:reply, state, state}
  end

  @impl GenServer
  def handle_call({:create_pledge, name, amount}, _from, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state, 2)
    new_state = [{name, amount} | most_recent_pledges]
    {:reply, id, new_state}
  end

  defp send_pledge_to_service(_name, _amount) do
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end
