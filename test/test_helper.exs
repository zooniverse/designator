ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Cellect.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Cellect.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Cellect.Repo)

