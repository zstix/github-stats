defmodule GithubStats.Charts do
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

  @text_style %{
    "font-family": "sans-serif",
    "font-size": "12px"
  }

  # TODO: abstract
  def draw_chart(%{title: title, data: data}, :burndown) do
    first = hd(data)
    chart_width = @width - @padding * 2
    chart_height = @height - @legend_height - @padding * 2
    chart_max = first.todo + first.in_progress + first.in_review + first.done
    num_lines = ceil(chart_max / 10)
    chart_gap = chart_height / num_lines

    chart_info = %{
      chart_bottom: @height - @padding - @legend_height,
      chart_height: chart_height,
      chart_width: chart_width,
      chart_max: chart_max,
      bar_width: (chart_width - length(data) * @bar_padding * 2) / length(data),
      num_lines: num_lines,
      chart_gap: chart_gap,
      burndown: [
        {:todo, @colors.blue},
        {:in_review, @colors.yellow},
        {:in_progress, @colors.green},
        {:done, @colors.gray}
      ]
    }

    %{width: @width, height: @height}
    |> Victor.new()
    |> draw_ideal_line(chart_info)
    |> draw_multi_bars(data, chart_info)
    |> draw_background(chart_info)
    |> draw_legend(chart_info, title)
    |> Victor.get_svg()
  end

  defp draw_legend(chart, info, title) do
    size = 15
    y = info.chart_bottom + @padding / 1.5

    info.burndown
    |> Enum.with_index()
    |> Enum.map(fn {item, pos} -> {@padding * 2 + pos * 120, item} end)
    |> Enum.reduce(chart, fn {x, {key, color}}, acc ->
      acc
      |> Victor.add(:rect, %{x: x, y: y, width: size, height: size}, %{fill: color})
      |> Victor.add(
        :text,
        %{x: x + size + 10, y: y + 10, content: key_to_string(key)},
        @text_style
      )
    end)
    |> Victor.add(
      :text,
      %{x: @padding, y: @height - @padding / 1.5, content: title},
      %{@text_style | "font-size": "18px"}
    )
  end

  defp key_to_string(key) do
    key
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end

  defp draw_ideal_line(chart, info) do
    chart
    |> Victor.add(
      :line,
      %{
        x1: @padding + @bar_padding * 2 + info.bar_width / 2,
        y1: info.chart_bottom - info.chart_max / 10 * info.chart_gap,
        x2: info.chart_width + @padding - info.bar_width / 2,
        y2: info.chart_bottom
      },
      %{stroke: @colors.red, "stroke-width": 2}
    )
  end

  defp draw_background(chart, info) do
    0..info.num_lines
    |> Enum.map(fn num -> info.chart_bottom - info.chart_gap * num end)
    |> Enum.map(fn y -> %{x1: @padding, y1: y, x2: @width - @padding, y2: y} end)
    |> Enum.with_index()
    |> Enum.reduce(chart, &draw_background_line/2)
  end

  defp draw_background_line({line, num}, chart) do
    line_color = (num == 0 && @colors.black) || @colors.gray

    chart
    |> Victor.add(:line, line, %{stroke: line_color, "stroke-width": 1})
    |> Victor.add(
      :text,
      %{x: @padding / 2, y: line.y1 + 3, content: "#{num * 10}"},
      @text_style
    )
  end

  defp draw_multi_bars(chart, data, info) do
    data
    |> Enum.with_index()
    |> Enum.reduce(chart, &draw_multi_bar(&2, &1, info))
  end

  defp draw_multi_bar(chart, {data, bar_pos}, info) do
    width = info.bar_width
    x = bar_pos * (width + @bar_padding * 2) + @padding + @bar_padding * 2

    label =
      data.date
      |> Date.to_string()
      |> String.split("-")
      |> Enum.take(-2)
      |> Enum.join("/")

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
    |> Victor.add(
      :text,
      %{
        x: x,
        y: info.chart_bottom + 15,
        content: label
      },
      @text_style
    )
  end

  defp get_height(data, key, info) do
    Map.get(data, key) / 10 * info.chart_gap
  end
end
