defmodule CimTest do
  use ExUnit.Case
  doctest Cim

  describe "offsets" do

    @tag :skip
    test "offset for first element should be 0" do

      start_time = ~N[2024-03-10 13:26:08.003]
      end_time = ~N[2024-03-10 15:26:08.003]

      item_count = 3

      assert(Cim.offsets(item_count, start_time, end_time) |> Enum.at(0) == 0)
    end

    @tag :skip
    test "offset for  should be 3600" do
      start_time = ~N[2024-03-10 13:26:08.003]
      end_time = ~N[2024-03-10 15:26:08.003]
      item_count = 2
      offsets = Cim.offsets(item_count, start_time, end_time)
      assert(offsets |> Enum.at(1) == 3600)
    end

    test "real run on temp" do
      images = Cim.image_list("/Users/zhon/trash")
      Cim.change_times(
        Enum.zip(
          images,
          Cim.offsets(length(images), DateTime.utc_now)
        ),
        {".NEF", ".XMP"}
      )

    end
  end

  describe "file gathering" do
    test "" do
      #assert Cim.find_image_rootname().length() >= 1 == :world
    end
  end
end
