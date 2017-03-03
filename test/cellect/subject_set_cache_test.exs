defmodule Cellect.SubjectSetCacheTest do
  use Cellect.ConnCase
  use Cellect.CacheCase

  alias Cellect.SubjectSetCache

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
      SubjectSetCache.set(key, %SubjectSetCache{reloading: true})
      assert SubjectSetCache.reload(key) == {:error, :already_reloading}
    end

    test "when loaded, but not reloading", %{key: key} do
      SubjectSetCache.set(key, %SubjectSetCache{})
      assert SubjectSetCache.reload(key) == :ok
    end
  end
end
