defmodule GithubCharts do
  @width 600
  @height 400
  @padding 40
  @legend_height 60
  @bar_padding 7

  # TODO:abstract

  # TODO: colors
  # TODO: title
  # TODO: legend
  def draw_chart(%{title: _title, data: data}, :burndown) do
    %{width: @width, height: @height}
    |> Victor.new()
    |> draw_background()
    |> draw_multi_bars(data)
    |> Victor.get_svg()
    |> Victor.write_file("./chart.svg")
  end

  defp draw_background(chart) do
    chart_bottom = @height - @padding - @legend_height
    line_style = %{stroke: "black", width: 2}
    line1 = %{x1: @padding, y1: @padding, x2: @padding, y2: chart_bottom}
    line2 = %{x1: @padding, y1: chart_bottom, x2: @width - @padding, y2: chart_bottom}

    chart
    |> Victor.add(:line, line1, line_style)
    |> Victor.add(:line, line2, line_style)
  end

  defp draw_multi_bars(chart, data) do
    chart_width = @width - @padding * 2

    first = hd(data)

    chart_info = %{
      chart_bottom: @height - @padding - @legend_height,
      chart_height: @height - @legend_height - @padding * 2,
      chart_width: chart_width,
      chart_max: first.todo + first.in_progress + first.in_review + first.done,
      bar_width: (chart_width - length(data) * @bar_padding * 2) / length(data),
      burndown: [
        {:todo, "blue"},
        {:in_review, "yellow"},
        {:in_progress, "green"},
        {:done, "grey"}
      ]
    }

    data
    |> Enum.with_index()
    |> Enum.reduce(chart, &draw_multi_bar(&2, &1, chart_info))
  end

  # TODO: dates below bars
  defp draw_multi_bar(chart, {data, bar_pos}, info) do
    width = info.bar_width
    x = bar_pos * (width + @bar_padding * 2) + @padding + @bar_padding

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
