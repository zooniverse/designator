# What is the difference between a "chance" and a "weight"

The chance is the absolute chance that the selection will choose a certain subject set to pull a random subject from. By default, this means that the chance will be set exactly equal to the number of subjects in the SubjectSet.

For instance, if you have 3 SubjectSets:

* [1,2,3,4]
* [5]
* [6]

The chances applied to them would be `4`, `1`, and `1`. The first SubjectSet would be four times as likely to have a subject selected from, which ultimately results in a uniform distribution at the per-subject level, every subject ends up with an equal probability of getting selected. (Note that only the relative value of chances to eachother is important, values of `0.8, 0.2, 0.2` would have the exact same result.)

It is possible to configure the `chance` directly in the workflow configuration. This will effectively say "I don't care how many subjects there are, always have this distribution between SubjectSets". For instance, if you have two sets, one with cats and one with dogs, and you want to present them at a 50/50 ratio even if you only have 20 cat images, and 80 dog images, you would configure the chances to be explicitly equal on both. 

Designator will then try to present images at that ratio, for as long as it's possible to do so. It is possible that you run into the situation where a user has seen all 20 cats already, and there are only dogs left, in which case it'd obviously only return dogs.

## Weights

Weights on the other hand are a multiplier, a way for you to signal that some set is "doubly important" compared to the other sets. The default weight for each SubjectSet is simply `1`.