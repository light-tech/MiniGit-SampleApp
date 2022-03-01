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
            // On Mac Catalyst, after clicking on this button, you can go to ~/Documents/ and checkout if there is the repository BigMac
            Button("Clone remote Git repo") {
                repo.clone(remoteRepoLocation)
            }
        }.padding(5)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
