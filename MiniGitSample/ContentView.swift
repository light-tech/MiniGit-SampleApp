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

let repository = GitRepository(localRepoLocation, credentialManager)

struct ContentView: View {

    @State var message = ""
    @ObservedObject var repo = repository
    @ObservedObject var commitGraph: GitCommitGraph = repository.commitGraph

    var body: some View {
        VStack {
            Text("On Mac Catalyst, you should be able to find the cloned repo in `~/Documents/`.").italic()

            Button("Clone remote Git repo") {
                repo.clone(remoteRepoLocation)
                // We want to do repo.updateCommitGraph() but this will be invoked
                // on main thread so likely before clone finishes in background thread.
                // We don't want to do another callback so maybe await/async.
            }

            if (repo.hasRepo) {
                // At the moment, clone will update hasRepo after completion. So this
                // has the effect of automatically update the UI if the clone is successful.
                List(commitGraph.commits) { commit in
                    VStack(alignment: .leading) {
                        Text(commit.message).bold()
                        Text(commit.author.name)
                    }
                }
                .listStyle(.plain)
                .onAppear {
                    repo.open()
                    if repo.exists() {
                        repo.updateCommitGraph()
                    }
                }
            }
        }.padding(5)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
