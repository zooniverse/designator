# What is StreamTools?

Short answer: it's magic. Assume that it does the following:

```ruby
while subject_sets.present?
  subject_set = choose_set_based_on_chances(subject_sets)
  subject = subject_set.random_subject()

  if subject
    yield subject
  else
    subject_sets.delete(subject_set)
  end
end
```

## Long answer

Going kind of step by step:

* `Selection.select` loads the workflow and user from the caches
* `Selection.select` then passes this over to `get_streams`
* `get_streams` loads the SubjectSetCache structs from the caches, and converts those into SubjectStream structs. A SubjectStream is something you can pull a random subject from with uniform distribution, but this is all lazily evaluated meaning no computation happens until you use something like `Enum.take(stream, 4)` to actually read from the stream. SubjectStreams also have chances, to be used later. After modifying the chances based on the configuration of the workflow, `get_streams` ultimately returns a list of these SubjectStreams.
* `do_select` then takes in this list of SubjectStreams, and passes them to `StreamTools.interleave`.
* `interleave` takes a list of streams (of subjects), and returns a combined single stream of subjects, taking the chances of the streams into account.
* `do_select` then ends up with a single stream, applies some filters:
  * remove subjects that were retired since the last cache reload
  * remove subjects that the user has classified already when their cache loaded
  * remove subjects that the user has been given in this session (this achieves the goal of not serving things a user has classified, without having to load the seen subject IDs from the database)
  * remove subjects that were duplicated (in case two sets have the same subject)
  And then ultimately takes a set number of subjects off the pipe after all the filters are taken into account. Remember that streams are lazy, so effectively we choose a random subject, then see if it passes through all the filters, and repeat that process until enough do.

## `interleave` and the tale of dragons

`StreamTools.interleave` is an implementation of Elixir's Enumerable protocol to define something that combines multiple (potentially infinite) streams into one single stream, by pulling at random from one of the streams until either no more elements are requested by the consumer, or no more elements are available from the producing streams.

The way in which streams work in Elixir is that a "stream" is actually a stream function that takes in a "stream state" `acc`, a command `:halt / :suspend / :cont` and an `emitter` function that the stream function should call with an element if it's called with the `:cont` command.

Halting and suspending are there because some streams might deal with actual IO, and might need to handle TCP connections etc. In our case, we don't really care about those, so let's instead focus on the `cont` command.

When an interleave-stream (again, this is just a function) receives a `cont` command, it selects a random subject set (taking into account the chances) from the state that was passed in. That subject set is itself a stream, so in order for the interleave-stream to emit an element, it then sends a `cont` command to that subject-set-stream.

Any stream when it can produce an element, will return the new stream-state. Which means that `interleave` than has to update its own state to replace that stream's state with the new one.

## `get_streams` and gold standard / training images

In the above, one simplication was applied. `get_streams` doesn't only modify the chances of the streams, it can also recombine them. Remember how `interleave` combines multiple streams by taking into account their relative chances, and then returns a single new stream? This process can also be applied in between to effectively create fewer, larger streams. The reason this is interesting is because you can take a few subject sets, and have their subjects all have uniform probability between them, but then still have the whole of them combined have a different probability.

In practice, this is how we supply users with training images. We take all of the streams relating to training subjects, and `interleave` them into a new stream. Do the same for all the non-training subjects. Now we have only two streams: training and non-training. We then look at the amount of classifications a user has made (or any other property of that user, could be skill level), and use that to determine that the chance for that user to pull a subject from any of the training subject sets should be. This chance is set directly on the training stream. Set the inverse of that chance on the non-training stream. 

Essentially, in Designator streams can be constructed into a tree structure with SubjectSets at the leaves, and a single stream at the root which is read from.