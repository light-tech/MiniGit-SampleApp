# MiniGit Sample Application

[MiniGit](https://github.com/light-tech/MiniGit) is designed to provide **data models** that can be bound to SwiftUI views.

Our main class `GitRepository` has one published member `hasRepo` which reflects whether the repository actually exists and is valid at the location (specified at construction): It is updated appropriately when `open`, `clone`, ... are invoked. 
 * Check this field before doing any operation and note that the repo needs to be `open`ed before performing any operations other than repository creation, namely `clone` and `create` a.k.a. git init.
 * Its other main members `status`, `commitGraph`, `remoteProgress`, `mergeProgress` are also observable and should publish their state changes when the operation are executed; such as remote progress during clone/push/fetch.
 * The intention of this two layers of observable implementation is so that when status change, we (i.e. SwiftUI) only need to invalidate the view for status, and not the view for the commit log (due to triggering view rebuilding in the repository). You can do
```swift
@ObservedObject var repo = repository
@ObservedObject var commitGraph: GitCommitGraph = repository.commitGraph
```
if you want the view to be rebuilt upon changes in the repo and the commit graph only.

If you are using XGit's more flexible version of `clone`, `push`, etc. (i.e. operations with progress reporting), you should clear the state of the progress object. For example:
```swift
repo.remoteProgress.clearState("Cloning from ...", credential)
repo.clone("https://...", ...)
```
MiniGit adds convenient versions of those method as the extra parameters are for progress reporting and `GitRepository` has a copy of those already.
Note that the API purposely uses `String` for remote repo because we want to support SSH repos as well and last time we check, Swift's [URL](https://developer.apple.com/documentation/foundation/url) does not support SSH protocol URLs.
