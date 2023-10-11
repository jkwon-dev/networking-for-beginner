//
//  ContentView.swift
//  networking-for-beginner1
//
//  Created by kwon eunji on 2023/10/05.
//

import SwiftUI

struct ContentView: View {
    @State private var user: GitHubUser?
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .foregroundColor(.secondary)
            }
            .frame(width: 120, height: 120)
            
            Text(user?.login ?? "Login Placeholder" )
                .bold()
                .font(.title3)
            
            Text(user?.bio ?? "User Bio Placeholder")
                .padding()
            
            Spacer()
        }
        .padding()
        .task {
            do {
                user = try await getUser()
            } catch GHEerror.invalidURL{
                print("Invaloid URL")
            } catch GHEerror.invalidResponse {
                print("Invalid Response")
            } catch GHEerror.invalidData {
                print("Invalid Data")
            } catch {
                print("Unexpected error")
            }
        }
    }
    
    //https://api.github.com/users/sallen0400
    
    func getUser() async throws -> GitHubUser {
        let endPoint = "https://api.github.com/users/twostraws"
        
        //string endPoint를 URL 객체를 만들어줌
        guard let url = URL(string: endPoint) else {throw GHEerror.invalidURL}
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHEerror.invalidResponse
        }
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GitHubUser.self, from: data)
        } catch {
            throw GHEerror.invalidData
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct GitHubUser: Codable {
    let login: String
    let avatarUrl: String
    let bio : String
}

enum GHEerror: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
