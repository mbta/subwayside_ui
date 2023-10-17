defmodule SubwaysideUi.GTFS.TrainCrowdingStatusTest do
  use ExUnit.Case, async: true
  alias SubwaysideUI.GTFS.TrainCrowdingStatus
  import Jason.Sigil

  @test_json_payload_path "test/data/VehiclePositions_enhanced.json"

  def get_gtfs_realtime_feed() do
    with {:ok, body} <- File.read(@test_json_payload_path), do: Jason.decode!(body)
  end

  describe "gtfs feed parsing" do
    test "properly assembles by-car map" do
      assert(
        TrainCrowdingStatus.get_gtfs_crowding_by_train() == %{
          "1473" => %{
            five_level_crowding: 1,
            occupancy_percentage: 7,
            occupancy_status: "MANY_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1402" => %{
            five_level_crowding: 1,
            occupancy_percentage: 5,
            occupancy_status: "MANY_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1458" => %{
            five_level_crowding: 2,
            occupancy_percentage: 8,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1422" => %{
            five_level_crowding: 2,
            occupancy_percentage: 12,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1429" => %{
            five_level_crowding: 2,
            occupancy_percentage: 14,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1433" => %{
            five_level_crowding: 2,
            occupancy_percentage: 13,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1431" => %{
            five_level_crowding: 1,
            occupancy_percentage: 6,
            occupancy_status: "MANY_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1466" => %{
            five_level_crowding: 1,
            occupancy_percentage: 2,
            occupancy_status: "MANY_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1459" => %{
            five_level_crowding: 1,
            occupancy_percentage: 3,
            occupancy_status: "MANY_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1425" => %{
            five_level_crowding: 1,
            occupancy_percentage: 8,
            occupancy_status: "MANY_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1906" => %{
            five_level_crowding: 2,
            occupancy_percentage: 10,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1438" => %{
            five_level_crowding: 1,
            occupancy_percentage: 7,
            occupancy_status: "MANY_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1441" => %{
            five_level_crowding: 2,
            occupancy_percentage: 14,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1467" => %{
            five_level_crowding: 2,
            occupancy_percentage: 9,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1477" => %{
            five_level_crowding: 2,
            occupancy_percentage: 13,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1411" => %{
            five_level_crowding: 1,
            occupancy_percentage: 8,
            occupancy_status: "MANY_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1455" => %{
            five_level_crowding: 2,
            occupancy_percentage: 9,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1442" => %{
            five_level_crowding: 2,
            occupancy_percentage: 9,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1462" => %{
            five_level_crowding: 2,
            occupancy_percentage: 14,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1436" => %{
            five_level_crowding: 2,
            occupancy_percentage: 10,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1410" => %{
            five_level_crowding: 1,
            occupancy_percentage: 6,
            occupancy_status: "MANY_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1440" => %{
            five_level_crowding: 2,
            occupancy_percentage: 15,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1453" => %{
            five_level_crowding: 1,
            occupancy_percentage: 2,
            occupancy_status: "MANY_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1472" => %{
            five_level_crowding: 2,
            occupancy_percentage: 12,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1418" => %{
            five_level_crowding: 2,
            occupancy_percentage: 17,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1417" => %{
            five_level_crowding: 1,
            occupancy_percentage: 6,
            occupancy_status: "MANY_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1493" => %{
            five_level_crowding: 2,
            occupancy_percentage: 9,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1430" => %{
            five_level_crowding: 2,
            occupancy_percentage: 8,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1437" => %{
            five_level_crowding: 2,
            occupancy_percentage: 13,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1476" => %{
            five_level_crowding: 2,
            occupancy_percentage: 15,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1406" => %{
            five_level_crowding: 1,
            occupancy_percentage: 6,
            occupancy_status: "MANY_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1489" => %{
            five_level_crowding: 2,
            occupancy_percentage: 17,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1492" => %{
            five_level_crowding: 1,
            occupancy_percentage: 6,
            occupancy_status: "MANY_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1423" => %{
            five_level_crowding: 2,
            occupancy_percentage: 11,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1488" => %{
            five_level_crowding: 3,
            occupancy_percentage: 21,
            occupancy_status: "STANDING_ROOM_ONLY",
            three_level_crowding: 2
          },
          "1428" => %{
            five_level_crowding: 2,
            occupancy_percentage: 14,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1439" => %{
            five_level_crowding: 1,
            occupancy_percentage: 6,
            occupancy_status: "MANY_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1415" => %{
            five_level_crowding: 3,
            occupancy_percentage: 22,
            occupancy_status: "STANDING_ROOM_ONLY",
            three_level_crowding: 2
          },
          "1407" => %{
            five_level_crowding: 1,
            occupancy_percentage: 2,
            occupancy_status: "MANY_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1416" => %{
            five_level_crowding: 2,
            occupancy_percentage: 9,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1457" => %{
            five_level_crowding: 1,
            occupancy_percentage: 6,
            occupancy_status: "MANY_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1468" => %{
            five_level_crowding: 2,
            occupancy_percentage: 10,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1909" => %{
            five_level_crowding: 2,
            occupancy_percentage: 12,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1454" => %{
            five_level_crowding: 2,
            occupancy_percentage: 12,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1451" => %{
            five_level_crowding: 1,
            occupancy_percentage: 5,
            occupancy_status: "MANY_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1446" => %{
            five_level_crowding: 2,
            occupancy_percentage: 13,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1486" => %{
            five_level_crowding: 1,
            occupancy_percentage: 6,
            occupancy_status: "MANY_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1491" => %{
            five_level_crowding: 2,
            occupancy_percentage: 15,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1444" => %{
            five_level_crowding: 2,
            occupancy_percentage: 13,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1432" => %{
            five_level_crowding: 2,
            occupancy_percentage: 9,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1452" => %{
            five_level_crowding: 1,
            occupancy_percentage: 5,
            occupancy_status: "MANY_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1424" => %{
            five_level_crowding: 2,
            occupancy_percentage: 8,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1490" => %{
            five_level_crowding: 1,
            occupancy_percentage: 4,
            occupancy_status: "MANY_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1475" => %{
            five_level_crowding: 2,
            occupancy_percentage: 13,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1463" => %{
            five_level_crowding: 2,
            occupancy_percentage: 9,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1474" => %{
            five_level_crowding: 2,
            occupancy_percentage: 13,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1443" => %{
            five_level_crowding: 1,
            occupancy_percentage: 4,
            occupancy_status: "MANY_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1413" => %{
            five_level_crowding: 1,
            occupancy_percentage: 4,
            occupancy_status: "MANY_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1487" => %{
            five_level_crowding: 1,
            occupancy_percentage: 6,
            occupancy_status: "MANY_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1465" => %{
            five_level_crowding: 1,
            occupancy_percentage: 8,
            occupancy_status: "MANY_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1460" => %{
            five_level_crowding: 2,
            occupancy_percentage: 17,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1456" => %{
            five_level_crowding: 1,
            occupancy_percentage: 8,
            occupancy_status: "MANY_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1908" => %{
            five_level_crowding: 2,
            occupancy_percentage: 16,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1403" => %{
            five_level_crowding: 1,
            occupancy_percentage: 4,
            occupancy_status: "MANY_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1434" => %{
            five_level_crowding: 2,
            occupancy_percentage: 15,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1419" => %{
            five_level_crowding: 2,
            occupancy_percentage: 15,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1435" => %{
            five_level_crowding: 1,
            occupancy_percentage: 6,
            occupancy_status: "MANY_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1445" => %{
            five_level_crowding: 2,
            occupancy_percentage: 17,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1911" => %{
            five_level_crowding: 2,
            occupancy_percentage: 9,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1414" => %{
            five_level_crowding: 2,
            occupancy_percentage: 16,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1447" => %{
            five_level_crowding: 1,
            occupancy_percentage: 8,
            occupancy_status: "MANY_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1464" => %{
            five_level_crowding: 1,
            occupancy_percentage: 6,
            occupancy_status: "MANY_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1910" => %{
            five_level_crowding: 2,
            occupancy_percentage: 14,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1469" => %{
            five_level_crowding: 1,
            occupancy_percentage: 7,
            occupancy_status: "MANY_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1450" => %{
            five_level_crowding: 1,
            occupancy_percentage: 7,
            occupancy_status: "MANY_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1412" => %{
            five_level_crowding: 2,
            occupancy_percentage: 10,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1461" => %{
            five_level_crowding: 2,
            occupancy_percentage: 15,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          },
          "1907" => %{
            five_level_crowding: 2,
            occupancy_percentage: 11,
            occupancy_status: "FEW_SEATS_AVAILABLE",
            three_level_crowding: 1
          }
        }
      )
    end
  end
end
