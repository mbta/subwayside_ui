defmodule SubwaysideUiWeb.HealthController do
  use SubwaysideUiWeb, :controller

  def index(conn, _params) do
    {code, response} =
      if SubwaysideUi.TrainStatus.has_trains?(SubwaysideUi.TrainStatus) do
        {:ok, "good"}
      else
        {:service_unavailable, "bad"}
      end

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(code, response)
  end
end
