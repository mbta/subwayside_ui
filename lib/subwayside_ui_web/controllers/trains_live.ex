defmodule SubwaysideUiWeb.TrainsLive do
  use SubwaysideUiWeb, :live_view

  def render(assigns) do
    ~H"""
    <.train :for={train <- @trains} train={train} now={@now} filtered?={!is_nil(@train_id)} />
    """
  end

  def train(assigns) do
    {:ok, created_date, _} = DateTime.from_iso8601(assigns.train["created_date"])
    latency = DateTime.diff(assigns.now, created_date, :second)
    assigns = assign(assigns, :latency, latency)

    ~H"""
    <div class="mb-8">
      <a class="text-blue-600" href={~p[/trains/#{@train["train_id"]}]}>
        <h1 class="text-3xl inline pl-2">
          <%= @train["leader_car_nbr"] %>
        </h1>
      </a>
      <span class="text-sm">
        (last updated <span title={@train["created_date"]}><%= @latency %>s ago</span>)
      </span>
      <table class="table-auto ml-2">
        <tbody>
          <tr :if={@train["route_name"]}>
            <td class="font-bold">Route</td>
            <td><%= @train["route_name"] %></td>
          </tr>
          <tr :if={@train["active_car_nbr"] != "0000"}>
            <td class="font-bold">Active Car No.</td>
            <td><%= @train["active_car_nbr"] %></td>
          </tr>
          <tr :if={@train["spv"]}>
            <td class="font-bold">Speed (MPH)</td>
            <td><%= @train["train_speed"] %></td>
          </tr>
          <tr :if={@train["gpv"]}>
            <td class="font-bold">Latitude</td>
            <td><%= @train["gps_latitude"] %></td>
          </tr>
          <tr :if={@train["gpv"]}>
            <td class="font-bold">Longitude</td>
            <td><%= @train["gps_longitude"] %></td>
          </tr>
        </tbody>
      </table>
      <table :if={is_map(@train["destination_loc"]) and @train["odv"]} class="table-auto">
        <thead>
          <tr>
            <th class="p-2 pb-0">
              <span :if={@train["running_distance"] == 0.0}>At Stop</span>
              <span :if={@train["running_distance"] != 0.0}>Previous Stop</span>
            </th>
            <th></th>
            <th class="p-2 pb-0">Next Stop</th>
            <th class="p-2 pb-0">Destination</th>
          </tr>
        </thead>
        <thead>
          <tr>
            <td class="pl-2 pr-2">
              <%= @train["present_loc"]["name"] %>
            </td>
            <td>
              <span :if={@train["running_distance"] != 0.0}>
                <span class="hero-arrow-small-right" />
                <%= Float.round(@train["running_distance"], 2) %> mi
                <span class="hero-arrow-small-right" />
              </span>
            </td>
            <td class="pl-2 pr-2"><%= @train["next_loc"]["name"] %></td>
            <td class="pl-2 pr-2"><%= @train["destination_loc"]["name"] %></td>
          </tr>
        </thead>
      </table>
      <table class="table-auto">
        <thead>
          <tr>
            <th class="p-2 pb-0">Car No.</th>
            <th class="p-2 pb-0">Passengers</th>
            <th class="p-2 pb-0">Weight (#)</th>
          </tr>
        </thead>
        <tbody>
          <.car :for={ci <- @train["car_infos"]} car={ci} />
        </tbody>
      </table>

      <div :if={@filtered?}>
        <h2 class="text-md">Flags</h2>
        <ul class="list-disc">
          <li :if={@train["train_critical"] == "1"}>Critical!</li>
          <li :if={@train["shop_mode_code"] == "1"}>Shop mode</li>
          <li :if={@train["hbv"]}>Heartbeat valid</li>
          <li :if={@train["hbl"]}>HBL, should never happen!</li>
          <li :if={@train["tdv"]}>Transmission datetime valid</li>
          <li :if={@train["tsc"]}>Time sync with WSS (invalid)</li>
          <li :if={!@train["tsc"]}>Time sync with GPS</li>
          <li :if={@train["odv"]}>Operation data (destination) valid</li>
          <li :if={@train["gpv"]}>GPS valid</li>
          <li :if={@train["spv"]}>Speed valid</li>
        </ul>
        <h2>Raw data</h2>
        <pre><%= Jason.encode_to_iodata!(@train, pretty: true) %></pre>
      </div>
    </div>
    """
  end

  def car(assigns) do
    car = assigns.car

    {:ok, car_base_weight} =
      SubwaysideUi.MinimumWeight.weight(SubwaysideUi.MinimumWeight, car["car_nbr"])

    car_weight = SubwaysideUi.car_weight(car["load_weight_sig_1"], car["load_weight_sig_2"])
    # weight is in 10s of pounds, and CRRC assumes that passengers are 155
    # pounds. We round down so that people can be pleasantly surprised.
    passengers = div(car_weight - car_base_weight, 15)

    assigns =
      assigns
      |> assign(:weight, car_weight)
      |> assign(:passengers, passengers)

    ~H"""
    <tr>
      <td class="pl-2 pr-2"><%= @car["car_nbr"] %></td>
      <td class="pl-2 pr-2"><%= @passengers %></td>
      <td class="pl-2 pr-2"><%= @weight * 10 %></td>
    </tr>
    """
  end

  def mount(params, _session, socket) do
    train_id =
      with {:ok, train_id} <- Map.fetch(params, "train_id"),
           {train_id, ""} <- Integer.parse(train_id) do
        train_id
      else
        _ -> nil
      end

    socket = assign(socket, :train_id, train_id)
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

    trains =
      if train_id = socket.assigns.train_id do
        if train = Map.get(trains, train_id) do
          [train]
        else
          []
        end
      else
        trains
        |> Map.values()
        |> Enum.sort_by(&Map.get(&1, "gps_latitude"), :desc)
      end

    assign(socket, :trains, trains)
  end
end
