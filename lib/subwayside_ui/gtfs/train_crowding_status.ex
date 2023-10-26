defmodule SubwaysideUi.GTFS.TrainCrowdingStatus do
  @moduledoc """
  Provides a few helper functions for quickly accessing crowding information on a
  per-car granularity.
  """

  def get_gtfs_realtime_feed do
    GenServer.call(SubwaysideUi.GTFS, :get_gtfs_feed)
  end

  def get_feed_func do
    Keyword.fetch!(Application.get_env(:subwayside_ui, __MODULE__), :feed_func)
  end

  def get_gtfs_crowding_by_train do
    {feed_mod, feed_func, feed_opts} = get_feed_func()
    gtfs = apply(feed_mod, feed_func, feed_opts)

    gtfs["entity"]
    |> Enum.map(&get_occupancy_for_entity/1)
    |> Enum.reduce(%{}, fn new, acc -> Map.merge(acc, new) end)
  end

  defp get_occupancy_for_entity(%{
         "vehicle" => %{"multi_carriage_details" => multi_carriage_details}
       }) do
    Enum.reduce(multi_carriage_details, %{}, fn carriage_details, carriage_acc ->
      occ_pct = carriage_details["occupancy_percentage"]
      occ_status = carriage_details["occupancy_status"]
      Map.put(carriage_acc, carriage_details["label"], get_crowding(occ_status, occ_pct))
    end)
  end

  defp get_occupancy_for_entity(_), do: []

  defp get_crowding(occ_status, occ_pct) do
    %{
      occupancy_percentage: occ_pct,
      occupancy_status: occ_status,
      three_level_crowding: get_three_level_crowding(occ_status),
      five_level_crowding: get_five_level_crowding(occ_status)
    }
  end

  def get_three_level_crowding(five_level_category) do
    case five_level_category do
      "MANY_SEATS_AVAILABLE" -> 1
      "FEW_SEATS_AVAILABLE" -> 1
      "STANDING_ROOM_ONLY" -> 2
      "CRUSHED_STANDING_ROOM_ONLY" -> 3
      "FULL" -> 3
      _ -> 0
    end
  end

  def get_five_level_crowding(five_level_category) do
    case five_level_category do
      "MANY_SEATS_AVAILABLE" -> 1
      "FEW_SEATS_AVAILABLE" -> 2
      "STANDING_ROOM_ONLY" -> 3
      "CRUSHED_STANDING_ROOM_ONLY" -> 4
      "FULL" -> 5
      _ -> 0
    end
  end
end
