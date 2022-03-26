//
//  ContentView.swift
//  MiniGit Sample App
//
//  Created by Lightech on 10/24/2048.
//

import SwiftUI
import MiniGit

let documentURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

let localRepoLocation = documentURL.appendingPathComponent("BigMac")

let remoteRepoLocation = "https://github.com/light-tech/BigMac.git"

// Do not do this in a real application, put the credentials somewhere safe
// And possibly encrypt them or keychain them by subclassing CredentialsManager
let credentialManager = CredentialsManager(credentialsFileUrl: documentURL.appendingPathComponent("gitcredentials"))

// For push/fetch to work, you might need to add the credential
var credentialAdded = false

func addCredential() {
    do {
        // TODO Change the info here
        try credentialManager.addOrUpdate(nil, Credential(id: "MyGithub", kind: .password, targetURL: "https://github.com/YOUR_USERNAME/", userName: "YOUR_USERNAME", password: "YOUR_ACCESS_TOKEN"))
        credentialAdded = true
        print("Credential added.")
    } catch let error {
        print("Fail to add credential:", error)
    }
}

let repository = GitRepository(localRepoLocation, credentialManager)

struct ContentView: View {

    @ObservedObject var repo = repository
    @ObservedObject var commitGraph = repository.commitGraph
    @ObservedObject var remoteProgress = repository.remoteProgress

    var body: some View {
        VStack {
            Text("On Mac Catalyst, you should be able to find the cloned repo in `~/Documents/`.").italic()

            Button("Clone remote Git repo") {
                repo.clone(remoteRepoLocation)
                // We want to do repo.updateCommitGraph() but this will be invoked
                // on main thread so likely before clone finishes in background thread.
                // We don't want to do another callback so maybe await/async.
            }

            if remoteProgress.inProgress {
                ProgressView(remoteProgress.operation)
            }

            if repo.hasRepo {
                // Hide the buttons if there are operations in progress
                if !remoteProgress.inProgress {
                    Button("Push to origin") {
                        let allRemotes = repo.getRemotes()     // get the list of remotes
                        let remoteOrigin = allRemotes[0]       // assuming you have only one remote i.e. origin
                        repo.push(remoteOrigin, false)         // push all branches to the corresponding one in origin
                    }

                    Button("Fetch from origin") {
                        let allRemotes = repo.getRemotes()
                        let remoteOrigin = allRemotes[0]
                        repo.fetch(remoteOrigin)
                    }

                    Button("Merge origin/master into current branch") {
                        repo.updateCommitGraph()
                        for c in repo.commitGraph.commits {
                            for ref in c.refs {
                                if ref.name == "refs/remotes/origin/master" {
                                    print("Found", ref.name)
                                     repo.merge([ref]) // merge the changes in the remote repo "origin/master" into the local "master"
                                }
                            }
                        }
                    }
                }

                // At the moment, clone will update hasRepo after completion. So this
                // has the effect of automatically update the UI if the clone is successful.
                List(commitGraph.commits) { commit in
                    VStack(alignment: .leading) {
                        Text(commit.message).bold()
                        Text(commit.author.name)
                    }
                }
                .listStyle(.plain)
            }
        }
        .padding(5)
        .onAppear {
            if !credentialAdded {
                addCredential()
            }
            repo.open()
            if repo.exists() {
                repo.updateCommitGraph()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
