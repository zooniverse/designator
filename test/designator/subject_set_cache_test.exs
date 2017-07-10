defmodule Designator.SubjectSetCacheTest do
  use Designator.ConnCase
  use Designator.CacheCase

  alias Designator.SubjectSetCache

  describe "reloading" do
    setup do
      {:ok, [key: {1, 2}]}
    end

    def get_cache_state(key) do
      ConCache.get(:subject_set_cache, key)
    end

    test "when not loaded yet", %{key: key} do
      assert SubjectSetCache.reload(key) == {:error, :not_existing}
      assert get_cache_state(key) == nil
    end

    test "when already reloading", %{key: key} do
      SubjectSetCache.set(key, %SubjectSetCache{loaded_at: DateTime.utc_now, reloading_since: DateTime.utc_now})
      assert SubjectSetCache.reload(key) == {:error, :already_reloading}
    end

    test "when already reloading but apparently stalled", %{key: key} do
      time = Timex.now |> Timex.shift(hours: -2)
      SubjectSetCache.set(key, %SubjectSetCache{loaded_at: DateTime.utc_now, reloading_since: time})
      assert SubjectSetCache.reload(key) == :ok
    end

    test "when loaded, but not reloading", %{key: key} do
      SubjectSetCache.set(key, %SubjectSetCache{})
      assert SubjectSetCache.reload(key) == :ok
    end
  end
end
