defmodule Mix.Tasks.ShowCarAt do
  @moduledoc """
  Mix tasks to show the raw data for a car at a given time(s).

  mix show_car_at <car number> <ISO timestamp> [<ISO timestamp>...]
  """
  alias SubwaysideUi.KinesisSource

  def run([car_nbr | iso_timestamps]) do
    date_times =
      for ts <- iso_timestamps do
        {:ok, dt, _} = DateTime.from_iso8601(ts)
        dt
      end

    [first_dt | _] = date_times = Enum.sort(date_times, DateTime)

    Application.ensure_all_started(:hackney)
    Application.ensure_all_started(:ex_aws)

    {:ok, pid} =
      KinesisSource.start_link(
        shard_iterator_type: :at_timestamp,
        shard_iterator_opts: %{
          "Timestamp" => DateTime.to_unix(first_dt)
        }
      )

    stream = GenStage.stream([{pid, max_demand: 10_000}])

    result = Enum.reduce_while(stream, {car_nbr, date_times}, &reducer/2)
    GenServer.stop(pid)
    System.stop(result)
  end

  defp reducer(
         %SubwaysideUi.Train{} = train,
         {car_nbr, [dt | remaining_dts] = dts}
       ) do
    if DateTime.compare(train.created_date, dt) == :gt do
      result = Enum.reduce_while(train.cars, car_nbr, &reducer_car_info/2)

      if result == car_nbr do
        {:cont, {car_nbr, dts}}
      else
        IO.puts(Jason.encode_to_iodata!(train.raw, pretty: true))
        {:cont, {car_nbr, remaining_dts}}
      end
    else
      {:cont, {car_nbr, dts}}
    end
  end

  defp reducer(_, {_, []}) do
    {:halt, 0}
  end

  defp reducer(
         %{
           "time" => record_timestamp,
           "data" => %{
             "car_infos" => car_infos
           }
         } = record,
         {car_nbr, dt}
       ) do
    {:ok, record_dt, _} = DateTime.from_iso8601(record_timestamp)

    if DateTime.compare(record_dt, dt) == :gt do
      result = Enum.reduce_while(car_infos, car_nbr, &reducer_car_info/2)

      if result == car_nbr do
        {:cont, {car_nbr, dt}}
      else
        IO.inspect(record, limit: :infinity)
        {:halt, result}
      end
    else
      ## IO.inspect(record_timestamp)
      {:cont, {car_nbr, dt}}
    end
  end

  defp reducer_car_info(car_info, car_nbr)

  defp reducer_car_info(%{car_nbr: car_nbr}, car_nbr) do
    {:halt, 0}
  end

  defp reducer_car_info(%{car_nbr: _car_nbr}, car_nbr) do
    {:cont, car_nbr}
  end

  defp reducer_car_info(%{"car_nbr" => car_nbr}, car_nbr) do
    {:halt, 0}
  end

  defp reducer_car_info(%{"car_nbr" => _}, car_nbr) do
    {:cont, car_nbr}
  end
end
