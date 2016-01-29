{:ok, workflow_manager} = Cellect.Workflow.Manager.start_link
{:ok, userseen_manager} = Cellect.UserSeen.Manager.start_link

request = fn i ->
  wpid = Cellect.Workflow.Manager.worker(workflow_manager, 338)
  upid = Cellect.UserSeen.Manager.worker(userseen_manager, 338, 1248176)
  IO.inspect Cellect.Selection.select_randomly(wpid, upid)
  if :random.uniform < 0.3 do Agent.stop(upid) end
end

Enum.map 1..10, request
