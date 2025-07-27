import SwiftUI

struct XComplaintPreviewView: View {
    @ObservedObject var xComplaintService: XComplaintService
    @Environment(\.dismiss) private var dismiss
    @State private var currentPostIndex: Int = 0
    
    var availablePosts: [XPost] {
        xComplaintService.availablePosts
    }
    
    var currentPost: XPost? {
        guard !availablePosts.isEmpty && currentPostIndex < availablePosts.count else {
            return nil
        }
        return availablePosts[currentPostIndex]
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "bubble.left.and.text.bubble.right")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        Text("X/Twitter Klage")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button("Lukk") {
                            dismiss()
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Text("Vel innlegg for å dela din frustrasjon på X")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)
                
                // Post preview card
                if let post = currentPost {
                    VStack(spacing: 16) {
                        // Post content
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Circle()
                                    .fill(.blue)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Text("B")
                                            .foregroundColor(.white)
                                            .fontWeight(.bold)
                                    )
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Bergenser")
                                        .fontWeight(.semibold)
                                    Text("@bergenser")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text("\(post.post.characters)/280")
                                    .font(.caption2)
                                    .foregroundColor(post.post.characters > 280 ? .red : .secondary)
                            }
                            
                            Text(post.post.text)
                                .font(.body)
                                .lineLimit(nil)
                                .multilineTextAlignment(.leading)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // Post navigation
                        if availablePosts.count > 1 {
                            HStack {
                                Button(action: {
                                    if currentPostIndex > 0 {
                                        currentPostIndex -= 1
                                        xComplaintService.selectPost(availablePosts[currentPostIndex])
                                    }
                                }) {
                                    Image(systemName: "chevron.left.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(currentPostIndex > 0 ? .blue : .gray)
                                }
                                .disabled(currentPostIndex == 0)
                                
                                Spacer()
                                
                                Text("\(currentPostIndex + 1) av \(availablePosts.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Button(action: {
                                    if currentPostIndex < availablePosts.count - 1 {
                                        currentPostIndex += 1
                                        xComplaintService.selectPost(availablePosts[currentPostIndex])
                                    }
                                }) {
                                    Image(systemName: "chevron.right.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(currentPostIndex < availablePosts.count - 1 ? .blue : .gray)
                                }
                                .disabled(currentPostIndex >= availablePosts.count - 1)
                            }
                            .padding(.horizontal)
                        }
                        
                        // Share button
                        Button(action: {
                            shareToX()
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Del på X")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.blue)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                } else {
                    Text("Ingen innlegg tilgjengelig for dette vêret")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding()
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            // Initialize with first available post
            if !availablePosts.isEmpty {
                currentPostIndex = 0
                xComplaintService.selectPost(availablePosts[0])
            }
        }
    }
    
    private func shareToX() {
        guard let post = currentPost else { return }
        
        let text = post.post.text
        let encodedText = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let twitterURL = "https://twitter.com/intent/tweet?text=\(encodedText)"
        
        if let url = URL(string: twitterURL) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    XComplaintPreviewView(xComplaintService: XComplaintService())
}