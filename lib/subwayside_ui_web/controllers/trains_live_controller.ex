defmodule SubwaysideUiWeb.TrainsLiveController do
  use SubwaysideUiWeb, :live_view

  def render(assigns) do
    ~H"""
    <%= for train <- @trains do %>
      <.train train={train} />
    <% end %>
    """
  end

  def train(assigns) do
    ~H"""
    <div class="mb-8">
      <div class="text-lg"><%= @train["leader_car_nbr"] %></div>
      <div>
        <%= for ci <- @train["car_infos"] do %>
          <div>
            <%= ci["car_nbr"] %> <%= ci["load_weight_sig_1"] * 10 %> <%= ci["load_weight_sig_2"] * 10 %>
          </div>
        <% end %>
      </div>
      <pre class="hidden">
        <%= Jason.encode_to_iodata!(@train, pretty: true) %>
      </pre>
    </div>
    """
  end

  def mount(_params, _assigns, socket) do
    trains = SubwaysideUi.TrainStatus.trains(SubwaysideUi.TrainStatus)

    sorted_trains =
      trains
      |> Map.values()
      |> Enum.sort_by(&Map.get(&1, "leader_car_nbr"))

    {:ok, assign(socket, :trains, sorted_trains)}
  end
end
