defmodule SubwaysideUi.GTFS do
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

  def handle_info(:tick, _gtfs) do
    gtfs = download_gtfs()
    tick()
    {:noreply, gtfs}
  end

  def handle_info(_, gtfs), do: {:noreply, gtfs}

  def download_gtfs do
    url = get_url()
    deserialized_body = Req.get!(url).body
    Logger.info(
          "SubwaysideUi.GTFS event=gtfs_update timestamp=#{:os.system_time(:millisecond)}"
        )
    deserialized_body
  end

  def get_url do
    Keyword.fetch!(Application.get_env(:subwayside_ui, __MODULE__), :url)
  end

  def handle_call(:get_gtfs_feed, _from, gtfs), do: {:reply, gtfs, gtfs}
end
