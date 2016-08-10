defmodule Cellect.SubjectSet do
  import Ecto.Query, only: [from: 2]

  def subject_ids(subject_set_id) do
    query = from set_member_subjects in "set_member_subjects",
      where: set_member_subjects.subject_set_id == ^subject_set_id,
      select: set_member_subjects.subject_id
    Cellect.Repo.all(query)
  end
end
