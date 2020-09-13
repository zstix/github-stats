defmodule GithubCharts do
  @width 600
  @height 400
  @padding 40
  @legend_height 60
  @bar_padding 8

  def draw_chart do
    data = [3, 3, 4, 5, 2]

    %{width: @width, height: @height}
    |> Victor.new()
    |> draw_background()
    |> draw_bars(data)
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

  defp draw_bars(chart, data) do
    chart_width = @width - @padding * 2

    chart_info = %{
      chart_bottom: @height - @padding - @legend_height,
      chart_height: @height - @legend_height - @padding * 2,
      chart_width: chart_width,
      chart_max: Enum.max(data),
      bar_width: (chart_width - length(data) * @bar_padding * 2) / length(data)
    }

    data
    |> Enum.with_index()
    |> Enum.reduce(chart, &draw_bar(&2, &1, chart_info))
  end

  defp draw_bar(chart, {val, pos}, info) do
    height = val / info.chart_max * info.chart_height
    width = info.bar_width

    chart
    |> Victor.add(:rect, %{
      x: pos * (width + @bar_padding * 2) + @padding + @bar_padding,
      y: info.chart_bottom - height,
      width: width,
      height: height
    })
  end
end
