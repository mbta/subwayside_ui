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
      <span class="text-lg"><%= @train["leader_car_nbr"] %></span>
      <span class="text-sm">(last updated <%= @train["created_date"] %>)</span>
      <%= if @train["destination_loc"] do %>
        <table>
          <tr>
            <th>Previous Stop</th>
            <th>Next Stop</th>
            <th>Destination</th>
          </tr>
          <tr>
            <td><%= @train["present_loc"]["name"] %></td>
            <td><%= @train["next_loc"]["name"] %></td>
            <td><%= @train["destination_loc"]["name"] %></td>
          </tr>
        </table>
      <% end %>
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
    socket = set_trains(socket)

    SubwaysideUi.TrainStatus.listen(SubwaysideUi.TrainStatus, self())

    {:ok, socket}
  end

  def handle_info(:new_trains, socket) do
    socket = set_trains(socket)
    {:noreply, socket}
  end

  defp set_trains(socket) do
    trains = SubwaysideUi.TrainStatus.trains(SubwaysideUi.TrainStatus)

    sorted_trains =
      trains
      |> Map.values()
      |> Enum.sort_by(&Map.get(&1, "leader_car_nbr"))

    assign(socket, :trains, sorted_trains)
  end
end
