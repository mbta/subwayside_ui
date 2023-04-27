defmodule SubwaysideUi.Train do
  @moduledoc """
  Structure to capture parsed information about an individual train consist.
  """
  alias SubwaysideUi.Car

  @type t() :: %__MODULE__{}

  defstruct [
    :id,
    :leader_car_nbr,
    :number_of_cars,
    :created_date,
    :receive_date,
    :route_name,
    :active_car_nbr,
    :speed,
    :gps_latitude,
    :gps_longitude,
    :destination_loc,
    :previous_loc,
    :next_loc,
    :running_distance,
    :flags,
    :cars,
    :raw
  ]

  defmodule Location do
    @moduledoc false
    defstruct [:name]

    def from_json_map(nil), do: nil

    def from_json_map(map) do
      %__MODULE__{
        name: map["name"]
      }
    end
  end

  defmodule Flags do
    @moduledoc false
    defstruct [
      :critical?,
      :shop_mode?,
      :heartbeat_valid?,
      :hbl,
      :speed_valid?,
      :gps_valid?,
      :destination_valid?,
      :datetime_valid?,
      :time_sync_wss?,
      :time_sync_gps?
    ]
  end

  @spec from_json_map(map) :: t()
  def from_json_map(%{} = map) do
    {:ok, created_date, _} = DateTime.from_iso8601(map["created_date"])
    {:ok, receive_date, _} = DateTime.from_iso8601(map["receive_date"])

    flags = %Flags{
      critical?: map["train_critical"] == "1",
      shop_mode?: map["show_mode_code"] == "1",
      heartbeat_valid?: map["hbv"],
      hbl: map["hbl"],
      speed_valid?: map["spv"],
      gps_valid?: map["gpv"],
      destination_valid?: map["odv"],
      datetime_valid?: map["tdv"],
      time_sync_wss?: map["tsc"],
      time_sync_gps?: !map["tsc"]
    }

    %__MODULE__{
      flags: flags,
      id: map["train_id"],
      leader_car_nbr: map["leader_car_nbr"],
      number_of_cars: map["number_of_cars"],
      created_date: created_date,
      receive_date: receive_date,
      route_name: map["route_name"],
      active_car_nbr: if(map["active_car_nbr"] != "0000", do: map["active_car_nbr"]),
      speed: if(flags.speed_valid?, do: map["train_speed"]),
      gps_latitude: if(flags.gps_valid?, do: map["gps_latitude"]),
      gps_longitude: if(flags.gps_valid?, do: map["gps_longitude"]),
      destination_loc: Location.from_json_map(map["destination_loc"]),
      previous_loc: Location.from_json_map(map["present_loc"]),
      next_loc: Location.from_json_map(map["next_loc"]),
      running_distance: map["running_distance"],
      cars:
        for(
          {ci, cl} <- Enum.zip(map["car_infos"], map["car_lists"]),
          do: Car.from_json_maps(ci, cl)
        ),
      raw: map
    }
  end
end
