defmodule SubwaysideUI.GTFS do
  @moduledoc """
  Keeps GTFS-RT in-memory for providing published crowding information.
  """
  use GenServer
  require Logger

  @tick_interval 1_000

  def start_link([]), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  def init(_) do
    tick()
    {:ok, %{}}
  end

  defp tick, do: Process.send_after(self(), :tick, @tick_interval)

  def handle_cast({:add, id}, tasks), do: {:noreply, MapSet.put(tasks, id)}

  def handle_cast({:remove, id}, tasks), do: {:noreply, MapSet.delete(tasks, id)}

  def handle_info(:tick, _gtfs) do
    gtfs = download_gtfs()
    tick()
    {:noreply, gtfs}
  end

  def handle_info(_, gtfs), do: {:noreply, gtfs}

  def download_gtfs do
    result = get_url() |> HTTPoison.get!()

    case result do
      %HTTPoison.Response{body: body, status_code: 200} ->
        deserialized_body =
          body
          |> Jason.decode!()

        Logger.info(
          "SubwaysideUI.GTFS event=gtfs_update timestamp=#{:os.system_time(:millisecond)}"
        )

        deserialized_body
    end
  end

  def get_url do
    Keyword.fetch!(Application.get_env(:subwayside_ui, __MODULE__), :url)
  end

  def handle_call(:get_gtfs_feed, _from, gtfs), do: {:reply, gtfs, gtfs}
end
