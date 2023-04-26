defmodule SubwaysideUi do
  @moduledoc """
  SubwaysideUi keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @doc """
  Returns the seated capacity (AW1) of a given CarInfo
  """
  def car_aw1(%{
        "car_type_code" => "1"
      }),
      do: 38

  def car_aw1(%{
        "car_type_code" => "2"
      }),
      do: 44

  @doc """
  Returns the comfortable capacity (AW2) of a given CarInfo
  """
  def car_aw2(%{
        "car_type_code" => "1"
      }),
      do: 132

  def car_aw2(%{
        "car_type_code" => "2"
      }),
      do: 142

  @doc "Return the correct weight of the car, given the two weight sensor values"
  def car_weight(weight_1, weight_2)
  def car_weight(0, weight), do: weight
  def car_weight(weight, 0), do: weight
  def car_weight(weight_1, weight_2), do: div(weight_1 + weight_2, 2)
end
