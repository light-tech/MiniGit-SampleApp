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

struct ContentView: View {

    @State var message = ""
    @StateObject var repo = GitRepository(localRepoLocation, credentialManager)

    var body: some View {
        VStack {
            Text("On Mac Catalyst, you should be able to find the cloned repo in `~/Documents/`.").italic()

            Button("Clone remote Git repo") {
                repo.clone(remoteRepoLocation)
            }

            // Unfortunately doing this won't refresh the commit history after cloning
            // Need an app restart to see the history
            // The solution is to make a new view binding to repo.commitGraph which is observable.
            List(repo.commitGraph.commits) { commit in
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
        }.padding(5)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
