defmodule Cim do
  @moduledoc """
  Documentation for `Cim`.
  """

  @doc """
  Change my image metadata

  ## Examples

      iex> Cim.hello()
      :world

  """

  use Application
  require Logger

  @spec start(any(), any()) :: {:error, any()} | {:ok, pid()}
  def start(type, args) do

    Cim.main(type, args)

    Supervisor.start_link([], strategy: :one_for_one)
  end

  def main(_type, _args) do
    start_time = ~N[2024-03-05 13:26:00]
    dir = "/Volumes/Current/Lightroom/2024/2024-03-05\ CuteEpoxide Pool Party Unselected/"


    images = Cim.image_list(dir)
    times = Cim.offsets(length(images), start_time)
    extensions = {".NEF", ".XMP"}

    {time, _} = :timer.tc(&Cim.change_times/3, [images, times, extensions ])
    Logger.info("change_times: #{time}")
    #Cim.change_times(images, times, extensions)
  end

  def offsets(count, start_time) do
    offsets(count, start_time, NaiveDateTime.add(start_time, 2, :hour))
  end

  def offsets(count, start_time, end_time) do
    diff = NaiveDateTime.diff(end_time, start_time)
    interval_length = div(diff, count)

    #Enum.map(0..(count-1), fn i -> NaiveDateTime.add(start_time, i * interval_length) end)
    Enum.map(0..(count-1), fn i ->
      Calendar.strftime(NaiveDateTime.add(start_time,
        i * interval_length),
        "%Y:%m:%d %H:%M:%S")
    end)
  end

  def image_list(dir, wildcard_extension \\ "*.NEF") do
    wild_card_path = Path.join(dir, wildcard_extension)
    Path.wildcard(wild_card_path) |> Enum.map( fn item -> Path.rootname(item) end)
  end

  def image_list() do
    wild_card_path = '/Volumes/Current/Lightroom/2024/2024-03-05 Ashley CuteEpoxide Pool Party/*.NEF'
    image_list(wild_card_path)
  end

  def images_offsets_zipped(images, offsets) do
    Enum.zip(images, offsets)
  end

  def change_times(images, times, extensions) do
    change_times(Enum.zip(images, times), extensions)
  end

  def change_times(image_times, extensions) do
    Stream.run(
      Task.async_stream(image_times, fn item ->
        change_time(item, extensions)
      end , [max_concurrency: 100, timeout: :infinity])
    )
  end

  def change_time(image_time, {ext1, ext2})  do
    {root_name, time} = image_time
    #Logger.info(root_name <> ext1 <> ", '#{time/1000}' seconds")
    {:ok, _metadata} = Exiftool.execute(["-Alldates=#{time}", "-overwrite_original_in_place", root_name <> ext1])
    {:ok, _metadata} = Exiftool.execute(["-Alldates=#{time}", "-overwrite_original_in_place", root_name <> ext2])
  end

end
