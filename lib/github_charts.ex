defmodule GithubCharts do
  @width 600
  @height 400
  @padding 40
  @legend_height 60
  @bar_padding 9

  @colors %{
    blue: "#6D9EEB",
    yellow: "#F9CB9C",
    green: "#93C47D",
    gray: "#B7B7B7",
    red: "#FF6D02",
    black: "#000000"
  }

  # TODO: title
  # TODO: legend
  # TODO: ideal
  # TODO: abstract
  def draw_chart(%{title: _title, data: data}, :burndown) do
    chart_width = @width - @padding * 2
    first = hd(data)

    chart_info = %{
      chart_bottom: @height - @padding - @legend_height,
      chart_height: @height - @legend_height - @padding * 2,
      chart_width: chart_width,
      chart_max: first.todo + first.in_progress + first.in_review + first.done,
      bar_width: (chart_width - length(data) * @bar_padding * 2) / length(data),
      burndown: [
        {:todo, @colors.blue},
        {:in_review, @colors.yellow},
        {:in_progress, @colors.green},
        {:done, @colors.gray}
      ]
    }

    %{width: @width, height: @height}
    |> Victor.new()
    |> draw_multi_bars(data, chart_info)
    |> draw_background(chart_info)
    |> Victor.get_svg()
    |> Victor.write_file("./chart.svg")
  end

  # TODO: left labels
  # TODO: title
  defp draw_background(chart, info) do
    num_lines = floor(info.chart_max / 10)
    chart_gap = info.chart_height / ceil(info.chart_max / 10)

    0..num_lines
    |> Enum.map(fn num -> info.chart_bottom - chart_gap * num end)
    |> Enum.map(fn y -> %{x1: @padding, y1: y, x2: @width - @padding, y2: y} end)
    |> Enum.with_index()
    |> Enum.reduce(chart, fn {line, num}, acc ->
      case num do
        0 -> Victor.add(acc, :line, line, %{stroke: @colors.black, width: 2})
        _ -> Victor.add(acc, :line, line, %{stroke: @colors.gray, width: 2})
      end
    end)
  end

  defp draw_multi_bars(chart, data, info) do
    data
    |> Enum.with_index()
    |> Enum.reduce(chart, &draw_multi_bar(&2, &1, info))
  end

  defp draw_multi_bar(chart, {data, bar_pos}, info) do
    width = info.bar_width
    x = bar_pos * (width + @bar_padding * 2) + @padding + @bar_padding * 2

    info.burndown
    |> Enum.with_index()
    |> Enum.map(fn {{key, color}, pos} ->
      {
        color,
        %{
          x: x,
          width: width,
          height: get_height(data, key, info),
          y:
            info.burndown
            |> Enum.take(pos + 1)
            |> Enum.map(fn {seg_key, _} -> get_height(data, seg_key, info) end)
            |> Enum.reduce(0, &(&1 + &2))
            |> (&(info.chart_bottom - &1)).()
        }
      }
    end)
    |> Enum.reduce(chart, fn {color, bar}, acc ->
      Victor.add(acc, :rect, bar, %{fill: color})
    end)
  end

  defp get_height(data, key, info) do
    Map.get(data, key) / info.chart_max * (info.chart_height - @padding)
  end
end
