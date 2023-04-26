defmodule ExAws.HttpClient.Finch do
  @moduledoc """
  ExAws.Request.HttpClient implementation which uses Finch
  """
  @behaviour ExAws.Request.HttpClient

  def request(method, url, body, headers, []) do
    request = Finch.build(method, url, headers, body)

    case Finch.request(request, SubwaysideUi.Finch) do
      {:ok, %{status: status_code, body: body, headers: headers}} ->
        {:ok, %{status_code: status_code, body: body, headers: headers}}

      {:error, reason} ->
        {:error, %{reason: reason}}
    end
  end
end
