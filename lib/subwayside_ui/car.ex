defmodule SubwaysideUi.Car do
  @moduledoc """
  Structure to capture parsed information about a single train car.
  """
  @type t() :: %__MODULE__{}
  defstruct [
    :car_nbr,
    :type_code,
    :weight
  ]

  @doc """
  Returns the seated capacity (AW1)
  """
  def aw1(%__MODULE__{type_code: code}) do
    case code do
      "1" -> 38
      "CAB" -> 38
      "2" -> 44
      "NON_CAB" -> 44
    end
  end

  @doc """
  Returns the comfortable capacity (AW2)
  """
  def aw2(%__MODULE__{type_code: code}) do
    case code do
      "1" -> 132
      "CAB" -> 132
      "2" -> 142
      "NON_CAB" -> 142
    end
  end

  def from_heartbeat(%{} = map) do
    [weight1, weight2] = map["loadWeightLb"]

    weight =
      case {weight1, weight2} do
        {0, weight} -> weight
        {weight, 0} -> weight
        {weight1, weight2} -> div(weight1 + weight2, 2)
      end

    %__MODULE__{
      car_nbr: map["nbr"] || map["carNumber"],
      type_code: map["type"],
      weight: weight
    }
  end

  def from_json_maps(%{} = info, %{} = _list) do
    weight1 = info["load_weight_sig_1"]
    weight2 = info["load_weight_sig_2"]

    weight =
      case {weight1, weight2} do
        {0, weight} -> weight
        {weight, 0} -> weight
        {weight1, weight2} -> div(weight1 + weight2, 2)
      end

    %__MODULE__{
      car_nbr: info["car_nbr"],
      type_code: info["car_type_code"],
      weight: weight * 10
    }
  end
end
