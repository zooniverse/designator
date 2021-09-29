## SubjectSet filtering for subject selection queries

### Current Behaviour

After [PR 121](https://github.com/zooniverse/designator/pull/121)

The behaviour of designator had two modes of operation, if a workflow is:
- set as not grouped
    + it will ignore the desired subject_set_id param and select from all linked subject sets
- set as grouped
    + it will only select data from the desired subject_set_id param (if found) or it will return no data
    
Thus the new behaviour respects the desired subject_set_id when a workflow is grouped and ignores it if not grouped.

### Old Behaviour
Before [PR 121](https://github.com/zooniverse/designator/pull/121)

The behaviour of designator allowed you to select from a particular subject set even if the workflow wasn’t set to grouped. 
However if that desired subject set was not found in the linked subject sets for a workflow, then the system would return data from ANY linked set in the workflow - thus returning data you may not expect.
