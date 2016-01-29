{:ok, workflow_manager} = Cellect.WorkflowManager.start_link
{:ok, userseen_manager} = Cellect.UserSeenManager.start_link

request = fn i ->
  wpid = Cellect.WorkflowManager.worker(workflow_manager, 338)
  upid = Cellect.UserSeenManager.worker(userseen_manager, 338, 1248176)
  IO.inspect Cellect.Selection.select_randomly(wpid, upid)
  if :random.uniform < 0.3 do Agent.stop(upid) end
end

Enum.map 1..10, request
