defmodule Metex.Worker do
  def loop do
    receive do
      {sender_pid, location} ->
        send(sender_pid, {:ok, temperature_of(location)})

      _ ->
        IO.puts("Don't know how to process this message")
    end

    loop()
  end

  def temperature_of(location) do
    result =
      location
      |> url_for()
      |> HTTPoison.get()
      |> parse_response()

    case result do
      {:ok, temp} ->
        "#{location}, #{temp}°C"

      :error ->
        "#{location} not found"
    end
  end

  defp url_for(location) do
    location = URI.encode(location)
    "http://api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{apikey()}"
  end

  defp computer_temperature(json) do
    try do
      temp = (json["main"]["temp"] - 273.15) |> Float.round(1)
      {:ok, temp}
    rescue
      _ -> :error
    end
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body
    |> JSON.decode!()
    |> computer_temperature()
  end

  defp parse_response(_) do
    :error
  end

  defp apikey do
    "b48bd9e55046731c6e4558248acc2304"
  end
end
