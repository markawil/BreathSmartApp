//
//  GithubUserView.swift
//  BreathSmartCBL
//
//  Created by Mark Wilkinson on 3/9/25.
//

import SwiftUI

struct GithubUserView: View {
    
    @Environment(\.presentationMode) private var mode
    @EnvironmentObject var viewModel: GithubUserViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                AsyncImage(url: URL(string: viewModel.user?.avatarUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                } placeholder: {
                    Circle()
                        .foregroundStyle(.secondary)
                    
                }
                .frame(width: 120, height: 120)
                
                Text("Github: " + viewModel.username)
                    .bold()
                    .font(.title3)
                Text(viewModel.user?.bio ?? "This is where the Github bio would go.")
                    .padding()
                Text("Feel free to contact me at:")
                Button {
                    if let url = URL(string: "mailto:markalanwil@gmail.com") {
                      UIApplication.shared.openURL(url)
                    }
                } label: {
                    Text("markalanwil@gmail.com")
                }
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        mode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                    }
                    .padding(.leading)
                    .tint(.black)
                }
            }
        }
    }
}

#Preview {
    GithubUserView()
        .environmentObject(GithubUserViewModel(username: "markawil"))
}
