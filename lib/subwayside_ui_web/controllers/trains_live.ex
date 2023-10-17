defmodule SubwaysideUiWeb.TrainsLive do
  use SubwaysideUiWeb, :live_view
  alias SubwaysideUi.GTFS.TrainCrowdingStatus

  def render(assigns) do
    trains =
      if assigns.train_id do
        assigns.trains
      else
        trains =
          if assigns.only_valid_gps? do
            Enum.filter(assigns.trains, & &1.flags.gps_valid?)
          else
            assigns.trains
          end

        trains =
          if assigns.only_full_consist? do
            Enum.filter(assigns.trains, &(&1.number_of_cars == 6))
          else
            trains
          end

        trains = filter_to_gtfs_trains(trains, assigns.gtfs_crowding)

        trains
      end

    assigns = assign(assigns, :trains, trains)

    ~H"""
    <h2 :if={@trains == []}>
      <svg
        class="animate-spin inline ml-1 h-5 w-5"
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
      >
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4">
        </circle>
        <path
          class="opacity-75"
          fill="currentColor"
          d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
        >
        </path>
      </svg>
      Loading trains in the background...
      <div class="pt-8" style="width:100%;height:0;padding-bottom:138%;position:relative;">
        <iframe
          src="https://giphy.com/embed/l1g3RddMFNWNcJ1wiD"
          width="100%"
          height="100%"
          style="position:absolute"
          frameBorder="0"
          class="giphy-embed"
          allowFullScreen
        >
        </iframe>
      </div>
      <p><a href="https://giphy.com/gifs/design-loop-l1g3RddMFNWNcJ1wiD">via GIPHY</a></p>
    </h2>
    <div :if={@trains != [] and is_nil(@train_id)}>
      <div>
        <input
          type="checkbox"
          id="valid-gps"
          checked={@only_valid_gps?}
          name="valid-gps"
          phx-click="toggle-valid-gps"
        />
        <label for="valid-gps">Only show trains with valid GPS</label>
      </div>
      <div>
        <input
          type="checkbox"
          id="full-consist"
          checked={@only_full_consist?}
          name="full-consit"
          phx-click="toggle-full-consist"
        />
        <label for="full-consist">Only show trains with a 6-car consist</label>
      </div>
      <div>Train count: <%= length(@trains) %></div>
    </div>
    <.train
      :for={train <- @trains}
      train={train}
      now={@now}
      filtered?={!is_nil(@train_id)}
      gtfs_crowding={assigns.gtfs_crowding}
    />
    """
  end

  def train(assigns) do
    train = assigns.train
    latency = DateTime.diff(assigns.now, train.created_date, :second)
    assigns = assign(assigns, :latency, latency)

    ~H"""
    <div class="mb-8">
      <.link class="text-blue-600" navigate={~p[/trains/#{@train.id}]}>
        <h1 class="text-3xl inline pl-2">
          <%= @train.leader_car_nbr %>
        </h1>
      </.link>
      <span class="text-sm">
        (last updated <span title={@train.created_date}><%= @latency %>s ago</span>)
      </span>
      <table class="table-auto ml-2">
        <tbody>
          <tr :if={@train.route_name}>
            <td class="font-bold">Route</td>
            <td><%= @train.route_name %></td>
          </tr>
          <tr :if={@train.active_car_nbr != "0000"}>
            <td class="font-bold">Active Car No.</td>
            <td><%= @train.active_car_nbr %></td>
          </tr>
          <tr :if={is_float(@train.speed)}>
            <td class="font-bold">Speed (MPH)</td>
            <td><%= @train.speed %></td>
          </tr>
          <tr :if={is_float(@train.gps_latitude)}>
            <td class="font-bold">Latitude</td>
            <td><%= @train.gps_latitude %></td>
          </tr>
          <tr :if={is_float(@train.gps_longitude)}>
            <td class="font-bold">Longitude</td>
            <td><%= @train.gps_longitude %></td>
          </tr>
        </tbody>
      </table>
      <table
        :if={is_map(@train.destination_loc) and @train.flags.destination_valid?}
        class="table-auto"
      >
        <thead>
          <tr>
            <th class="p-2 pb-0">
              <span :if={@train.running_distance == 0.0}>At Stop</span>
              <span :if={@train.running_distance != 0.0}>Previous Stop</span>
            </th>
            <th></th>
            <th class="p-2 pb-0">Next Stop</th>
            <th class="p-2 pb-0">Destination</th>
          </tr>
        </thead>
        <thead>
          <tr>
            <td class="pl-2 pr-2">
              <%= @train.previous_loc.name %>
            </td>
            <td>
              <span :if={@train.running_distance != 0.0}>
                <span class="hero-arrow-small-right" />
                <%= Float.round(@train.running_distance, 2) %> mi
                <span class="hero-arrow-small-right" />
              </span>
            </td>
            <td class="pl-2 pr-2"><%= @train.next_loc.name %></td>
            <td class="pl-2 pr-2"><%= @train.destination_loc.name %></td>
          </tr>
        </thead>
      </table>
      <table class="table-auto">
        <thead>
          <tr>
            <th class="p-2 pb-0">Car No.</th>
            <th class="p-2 pb-0">Passengers</th>
            <th class="p-2 pb-0">Crowding</th>
            <th class="p-2 pb-0">5-Level Crowding</th>
            <th class="p-2 pb-0">Occupancy</th>
            <th class="p-2 pb-0">Weight (#)</th>
            <th class="p-2 pb-0">Empty Weight (#)</th>
          </tr>
        </thead>
        <tbody>
          <.car :for={car <- @train.cars} car={car} gtfs_crowding={assigns.gtfs_crowding} />
        </tbody>
      </table>

      <div :if={@filtered?}>
        <h2 class="text-md">Flags</h2>
        <ul class="list-disc">
          <li :if={@train.flags.critical?}>Critical!</li>
          <li :if={@train.flags.shop_mode?}>Shop mode</li>
          <li :if={@train.flags.heartbeat_valid?}>Heartbeat valid</li>
          <li :if={@train.flags.hbl}>HBL, should never happen!</li>
          <li :if={@train.flags.datetime_valid?}>Transmission datetime valid</li>
          <li :if={@train.flags.time_sync_wss?}>Time sync with WSS (invalid)</li>
          <li :if={@train.flags.time_sync_gps?}>Time sync with GPS</li>
          <li :if={@train.flags.destination_valid?}>Operation data (destination) valid</li>
          <li :if={@train.flags.gps_valid?}>GPS valid</li>
          <li :if={@train.flags.speed_valid?}>Speed valid</li>
        </ul>
        <h2>Raw data</h2>
        <pre><%= Jason.encode_to_iodata!(@train.raw, pretty: true) %></pre>
      </div>
    </div>
    """
  end

  defp get_gtfs_three_crowding_text(category) do
    case category do
      0 -> "Bad Data"
      1 -> "Not crowded"
      2 -> "Some crowding"
      3 -> "Crowded"
    end
  end

  defp get_gtfs_five_crowding_text(category) do
    case category do
      0 -> "Bad Data"
      1 -> "Many Seats Available"
      2 -> "Few Seats Available"
      3 -> "Standing Room Only"
      4 -> "Crushed Standing Room Only"
      5 -> "Full"
    end
  end

  def car(assigns) do
    car = assigns.car

    {:ok, car_base_weight} =
      SubwaysideUi.MinimumWeight.weight(SubwaysideUi.MinimumWeight, car.car_nbr)

    # CRRC assumes that passengers are 155
    # pounds. We round down so that people can be pleasantly surprised.
    passengers = div(car.weight - car_base_weight, 155)
    seated_capacity = SubwaysideUi.Car.aw1(car)

    gtfs_crowding_five_category =
      if Map.has_key?(assigns.gtfs_crowding, car.car_nbr) do
        assigns.gtfs_crowding[car.car_nbr].five_level_crowding
      else
        0
      end

    gtfs_crowding_three_category =
      if Map.has_key?(assigns.gtfs_crowding, car.car_nbr) do
        assigns.gtfs_crowding[car.car_nbr].three_level_crowding
      else
        0
      end

    occupancy_percentage =
      if Map.has_key?(assigns.gtfs_crowding, car.car_nbr) do
        assigns.gtfs_crowding[car.car_nbr].occupancy_percentage
      else
        0
      end

    gtfs_three_crowding_text = get_gtfs_three_crowding_text(gtfs_crowding_three_category)

    gtfs_five_crowding_text = get_gtfs_five_crowding_text(gtfs_crowding_five_category)

    gtfs_three_filled_classes = List.duplicate("hero-user-solid", gtfs_crowding_three_category)

    unfilled_three =
      if length(gtfs_three_filled_classes) != 0,
        do: 3 - length(gtfs_three_filled_classes),
        else: 0

    gtfs_three_unfilled_classes = List.duplicate("hero-user", unfilled_three)

    gtfs_five_filled_classes = List.duplicate("hero-user-solid", gtfs_crowding_five_category)

    unfilled_five =
      if length(gtfs_five_filled_classes) != 0, do: 5 - length(gtfs_five_filled_classes), else: 0

    gtfs_five_unfilled_classes = List.duplicate("hero-user", unfilled_five)

    assigns =
      assigns
      |> assign(:weight, car.weight)
      |> assign(:empty_weight, car_base_weight)
      |> assign(:seated_capacity, seated_capacity)
      |> assign(:passengers, passengers)
      |> assign(:occupancy_percentage, occupancy_percentage)
      |> assign(:gtfs_three_crowding_text, gtfs_three_crowding_text)
      |> assign(:gtfs_five_crowding_text, gtfs_five_crowding_text)
      |> assign(:gtfs_five_pin_classes, gtfs_five_filled_classes ++ gtfs_five_unfilled_classes)
      |> assign(:gtfs_three_pin_classes, gtfs_three_filled_classes ++ gtfs_three_unfilled_classes)

    ~H"""
    <tr>
      <td class="pl-2 pr-2"><%= @car.car_nbr %></td>
      <td class="pl-2 pr-2"><%= @passengers %></td>
      <td class="pl-2 pr-2">
        <span title={@gtfs_three_crowding_text} class="inline">
          <span :for={class <- @gtfs_three_pin_classes} class={"#{class} inline-block w-5"} />
        </span>
        <br />
        <%!-- <%= @gtfs_three_crowding_text %> --%>
      </td>
      <td class="pl-2 pr-2">
        <span title={@gtfs_five_crowding_text} class="inline">
          <span :for={class <- @gtfs_five_pin_classes} class={"#{class} inline-block w-5"} />
        </span>
        <br />
        <%!-- <%= @gtfs_five_crowding_text %> --%>
      </td>
      <td class="pl-2 pr-2"><%= @occupancy_percentage %>%</td>
      <!-- End GTFS Crowding -->
      <td class="pl-2 pr-2"><%= @weight %></td>
      <td class="pl-2 pr-2"><%= @empty_weight %></td>
    </tr>
    """
  end

  def mount(params, _session, socket) do
    train_id =
      case Map.fetch(params, "train_id") do
        {:ok, train_id} -> train_id
        _ -> nil
      end

    :timer.send_interval(1_000, :now)

    socket =
      socket
      |> assign(:train_id, train_id)
      |> assign(:only_valid_gps?, false)
      |> assign(:only_full_consist?, true)

    socket = set_now(socket)

    gtfs_crowding = TrainCrowdingStatus.get_gtfs_crowding_by_train()
    socket = set_gtfs_crowding(socket, gtfs_crowding)

    trains = SubwaysideUi.TrainStatus.listen(SubwaysideUi.TrainStatus, self())
    socket = set_trains(socket, trains)

    {:ok, socket}
  end

  def handle_event("toggle-valid-gps", _, socket) do
    {:noreply, assign(socket, :only_valid_gps?, !socket.assigns.only_valid_gps?)}
  end

  def handle_event("toggle-full-consist", _, socket) do
    {:noreply, assign(socket, :only_full_consist?, !socket.assigns.only_full_consist?)}
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

  defp set_trains(socket, trains \\ nil) do
    trains = trains || SubwaysideUi.TrainStatus.trains(SubwaysideUi.TrainStatus)

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
        |> Enum.sort_by(& &1.gps_latitude, :desc)
      end

    page_title =
      case trains do
        [train] -> train.leader_car_nbr
        _ -> "Trains"
      end

    socket
    |> assign(:page_title, page_title)
    |> assign(:trains, trains)
  end

  defp set_gtfs_crowding(socket, gtfs_crowding) do
    gtfs_crowding =
      gtfs_crowding || SubwaysideUi.GTFS.TrainCrowdingStatus.get_gtfs_crowding_by_train()

    socket
    |> assign(:gtfs_crowding, gtfs_crowding)
  end

  defp filter_to_gtfs_trains(trains, gtfs_crowding) do
    if get_only_show_gtfs() do
      Enum.filter(trains, fn train ->
        train.cars
        |> Enum.map(fn car -> car.car_nbr end)
        # We should still show trains where a car is missing:
        |> Enum.any?(&Enum.member?(Map.keys(gtfs_crowding), &1))
      end)
    else
      trains
    end
  end

  defp get_only_show_gtfs do
    Keyword.fetch!(Application.get_env(:subwayside_ui, SubwaysideUi.GTFS), :only_show_gtfs)
  end
end
