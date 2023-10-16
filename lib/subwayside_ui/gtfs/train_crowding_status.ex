defmodule SubwaysideUI.GTFS.TrainCrowdingStatus do
  @moduledoc """
  Provides a few helper functions for quickly accessing crowding information on a
  per-car granularity.
  """

  def get_gtfs_crowding_by_train do
    gtfs = GenServer.call(SubwaysideUI.GTFS, :get_gtfs_feed)

    gtfs["entity"]
    |> Enum.filter(fn entity ->
      Map.has_key?(entity, "vehicle") and Map.has_key?(entity["vehicle"], "vehicle")
    end)
    |> Enum.map(&get_occupancy_for_entity/1)
    |> Enum.reduce(%{}, fn new, acc -> Map.merge(acc, new) end)
  end

  defp get_occupancy_for_entity(%{
         "vehicle" => %{"vehicle" => %{"label" => vehicle_label}} = vehicle
       }) do
    has_root_occupancy = Map.has_key?(vehicle, "occupancy_status")
    has_multi_carriage_details = Map.has_key?(vehicle, "multi_carriage_details")

    result_acc =
      if has_root_occupancy do
        occ_pct = vehicle["occupancy_percentage"]
        occ_status = vehicle["occupancy_status"]

        %{
          vehicle_label => get_crowding(occ_status, occ_pct)
        }
      else
        %{}
      end

    if has_multi_carriage_details do
      Map.merge(
        result_acc,
        Enum.reduce(vehicle["multi_carriage_details"], %{}, fn carriage_details, carriage_acc ->
          occ_pct = carriage_details["occupancy_percentage"]
          occ_status = carriage_details["occupancy_status"]
          Map.put(carriage_acc, carriage_details["label"], get_crowding(occ_status, occ_pct))
        end)
      )
    else
      result_acc
    end
  end

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
