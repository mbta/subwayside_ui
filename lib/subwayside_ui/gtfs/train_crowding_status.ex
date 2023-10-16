defmodule SubwaysideUI.GTFS.TrainCrowdingStatus do
  def get_gtfs_crowding_by_train do
    gtfs = GenServer.call(SubwaysideUI.GTFS, :get_gtfs_feed)

    gtfs["entity"]
    |> Enum.reduce(%{}, fn vehicle, result_acc ->
      has_vehicle = Map.has_key?(vehicle, "vehicle")
      if has_vehicle do
        sub_vehicle = vehicle["vehicle"]
        vehicle_label = sub_vehicle["label"]
        has_root_occupancy = Map.has_key?(vehicle, "occupancy_status")
        if has_root_occupancy do
          occ_pct = vehicle["occupancy_percentage"]
          occ_status = vehicle["occupancy_status"]
          ^result_acc = Map.merge(result_acc, %{
            vehicle_label => %{
              occupancy_percentage: occ_pct,
              occupancy_status: occ_status,
              three_level_crowding: get_three_level_crowding(occ_status),
              five_level_crowding: get_five_level_crowding(occ_status)
            }
          })
        end
        has_multi_carriage_details = Map.has_key?(sub_vehicle, "multi_carriage_details")
        if has_multi_carriage_details do
          Map.merge(
            result_acc,
            Enum.reduce(sub_vehicle["multi_carriage_details"], %{}, fn carriage_details,
                                                                       carriage_acc ->
              occ_pct = carriage_details["occupancy_percentage"]
              occ_status = carriage_details["occupancy_status"]
              Map.put(carriage_acc, carriage_details["label"], %{
                occupancy_percentage: occ_pct,
                occupancy_status: occ_status,
                three_level_crowding: get_three_level_crowding(occ_status),
                five_level_crowding: get_five_level_crowding(occ_status)
              })
            end)
          )
        else
          result_acc
        end
      else
        result_acc
      end
    end)
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
