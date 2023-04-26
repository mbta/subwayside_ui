defmodule SubwaysideUi do
  @moduledoc """
  SubwaysideUi keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @doc "Return the correct weight of the car, given the two weight sensor values"
  def car_weight(weight_1, weight_2)
  def car_weight(0, weight), do: weight
  def car_weight(weight, 0), do: weight
  def car_weight(weight_1, weight_2), do: div(weight_1 + weight_2, 2)
end
