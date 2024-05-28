import Foundation
import Vapor

extension FCM {
    public func deleteTopic(_ name: String, tokens: String...) async throws {
        try await deleteTopic(name, tokens: tokens)
    }

    public func deleteTopic(_ name: String, tokens: [String]) async throws {
        try await _deleteTopic(name, tokens: tokens)
    }

    private func _deleteTopic(_ name: String, tokens: [String]) async throws {
        guard let serverKey = configuration.serverKey else {
            fatalError("FCM: DeleteTopic: Server Key is missing.")
        }
        
        let url = iidURL + "batchRemove"
        let accessToken = try await getAccessToken()
        var headers = HTTPHeaders()
        headers.add(name: .authorization, value: "key=\(serverKey)")
        
        let res = try await client.post(URI(string: url), headers: headers) { req in
            struct Payload: Content {
                let to: String
                let registration_tokens: [String]
                
                init(to: String, registration_tokens: [String]) {
                    self.to = "/topics/\(to)"
                    self.registration_tokens = registration_tokens
                }
            }
            let payload = Payload(to: name, registration_tokens: tokens)
            try req.content.encode(payload)
        }
    }
}
