defmodule GithubCharts do
  @width 600
  @height 400
  @padding 40
  @legend_height 60
  @bar_padding 5

  # TODO: colors
  # TODO: title
  # TODO: legend
  def draw_chart(%{title: _title, data: data}, :burndown) do
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

    first = hd(data)

    chart_info = %{
      chart_bottom: @height - @padding - @legend_height,
      chart_height: @height - @legend_height - @padding * 2,
      chart_width: chart_width,
      chart_max: first.todo + first.in_progress + first.in_review + first.done,
      bar_width: (chart_width - length(data) * @bar_padding * 2) / length(data)
    }

    data
    |> Enum.with_index()
    |> Enum.reduce(chart, &draw_bar(&2, &1, chart_info))
  end

  # TODO: points above bars
  # TODO: dates below bars
  defp draw_bar(chart, {data, pos}, info) do
    width = info.bar_width
    x = pos * (width + @bar_padding * 2) + @padding + @bar_padding

    todo_height = data.todo / info.chart_max * (info.chart_height - @padding)
    in_progress_height = data.in_progress / info.chart_max * (info.chart_height - @padding)
    in_review_height = data.in_review / info.chart_max * (info.chart_height - @padding)

    todo_bar = %{
      x: x,
      y: info.chart_bottom - todo_height,
      width: width,
      height: todo_height
    }

    in_progress_bar = %{
      x: x,
      y: info.chart_bottom - todo_height - in_progress_height,
      width: width,
      height: in_progress_height
    }

    in_review_bar = %{
      x: x,
      y: info.chart_bottom - todo_height - in_progress_height - in_review_height,
      width: width,
      height: in_review_height
    }

    chart
    |> Victor.add(:rect, todo_bar, %{fill: "red"})
    |> Victor.add(:rect, in_progress_bar, %{fill: "orange"})
    |> Victor.add(:rect, in_review_bar, %{fill: "teal"})
  end
end
