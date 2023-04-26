defmodule SubwaysideUiWeb.TrainsLiveController do
  use SubwaysideUiWeb, :live_view

  def render(assigns) do
    ~H"""
    <%= for train <- @trains do %>
      <.train train={train} now={@now} />
    <% end %>
    """
  end

  def train(assigns) do
    {:ok, created_date, _} = DateTime.from_iso8601(assigns.train["created_date"])
    latency = DateTime.diff(assigns.now, created_date, :second)
    assigns = assign(assigns, :latency, latency)

    ~H"""
    <div class="mb-8">
      <h1 class="text-xl inline pl-2"><%= @train["leader_car_nbr"] %></h1>
      <span class="text-sm">
        (last updated <span title={@train["created_date"]}><%= @latency %>s ago</span>)
      </span>
      <%= if @train["destination_loc"] do %>
        <table class="table-auto">
          <thead>
            <tr>
              <th class="p-2">Previous Stop</th>
              <th class="p-2">Next Stop</th>
              <th class="p-2">Destination</th>
            </tr>
          </thead>
          <thead>
            <tr>
              <td class="p-2"><%= @train["present_loc"]["name"] %></td>
              <td class="p-2"><%= @train["next_loc"]["name"] %></td>
              <td class="p-2"><%= @train["destination_loc"]["name"] %></td>
            </tr>
          </thead>
        </table>
      <% end %>
      <table class="table-auto">
        <thead>
          <tr>
            <th class="p-2">Car No.</th>
            <th class="p-2">Weight 1 (#)</th>
            <th class="p-2">Weight 2 (#)</th>
          </tr>
        </thead>
        <tbody>
          <%= for ci <- @train["car_infos"] do %>
            <tr>
              <td class="p-2"><%= ci["car_nbr"] %></td>
              <td class="p-2"><%= ci["load_weight_sig_1"] * 10 %></td>
              <td class="p-2"><%= ci["load_weight_sig_2"] * 10 %></td>
            </tr>
          <% end %>
        </tbody>
      </table>
      <pre class="hidden">
        <%= Jason.encode_to_iodata!(@train, pretty: true) %>
      </pre>
    </div>
    """
  end

  def mount(_params, _assigns, socket) do
    socket = set_now(socket)
    socket = set_trains(socket)

    :timer.send_interval(1_000, :now)
    SubwaysideUi.TrainStatus.listen(SubwaysideUi.TrainStatus, self())

    {:ok, socket}
  end

  def handle_info(:now, socket) do
    socket = set_now(socket)
    {:noreply, socket}
  end

  def handle_info(:new_trains, socket) do
    socket = set_trains(socket)
    {:noreply, socket}
  end

  defp set_now(socket) do
    assign(socket, :now, DateTime.utc_now())
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
