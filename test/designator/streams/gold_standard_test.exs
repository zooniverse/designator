defmodule Designator.Streams.GoldStandardTest do
  use ExUnit.Case

  import Designator.Streams.GoldStandard

  test "gold chance" do
    assert gold_chance(0) == 0.4
    assert gold_chance(1) == 0.4
    assert gold_chance(19) == 0.4
    assert gold_chance(20) == 0.4

    assert gold_chance(21) == 0.3
    assert gold_chance(39) == 0.3
    assert gold_chance(40) == 0.3

    assert gold_chance(41) == 0.2
    assert gold_chance(59) == 0.2
    assert gold_chance(60) == 0.2

    assert gold_chance(61) == 0.1
    assert gold_chance(70) == 0.1
    assert gold_chance(1200) == 0.1
  end
end
