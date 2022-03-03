# MiniGit Sample Application

[MiniGit](https://github.com/light-tech/MiniGit) is designed to provide **data models** that can be bound to SwiftUI views.

The main class `GitRepository` has one published member `hasRepo` which reflects whether the repository actually exists and is valid at the location (specified at construction): It is updated appropriately when `open`, `clone`, ... are invoked.
Its other main members `status`, `commitGraph`, `remoteProgress`, `mergeProgress` are also observable.
The intention of this two layers of observable implementation is so that when status change, we (i.e. SwiftUI) only need to invalidate the view for status, and not the view for the commit log (due to triggering view rebuilding in the repository).
You could still do
```swift
    @ObservedObject var repo = repository
    @ObservedObject var commitGraph: GitCommitGraph = repository.commitGraph
```
if you want the view to be rebuilt upon changes in the repo and the commit graph only, as in this sample app.
