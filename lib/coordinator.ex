defmodule Metex.Coordinator do
  def loop(results \\ [], results_expected_count) do
    receive do
      {:ok, result} ->
        new_resluts = [result | results]

        if results_expected_count == Enum.count(new_resluts) do
          send(self(), :exit)
        end

        loop(new_resluts, results_expected_count)

      :exit ->
        IO.puts(results |> Enum.sort() |> Enum.join(", "))

      _ ->
        loop(results, results_expected_count)
    end
  end
end
