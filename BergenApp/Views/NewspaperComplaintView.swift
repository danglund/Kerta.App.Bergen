import SwiftUI

struct NewspaperComplaintView: View {
    @ObservedObject var complaintService: NewspaperComplaintService
    let complaintText: String
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Newspaper selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Vel avis:")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(complaintService.newspapers) { newspaper in
                                Button(action: {
                                    complaintService.selectNewspaper(newspaper)
                                }) {
                                    Text(newspaper.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(complaintService.selectedNewspaper?.id == newspaper.id ? .white : .primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(complaintService.selectedNewspaper?.id == newspaper.id ? Color.blue : Color.gray.opacity(0.2))
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Template selection (show available templates for current weather)
                if complaintService.availableTemplates.count > 1 {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Vel mal:")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(complaintService.availableTemplates) { template in
                                    Button(action: {
                                        complaintService.selectTemplate(template)
                                    }) {
                                        Text(template.title)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(complaintService.selectedTemplate?.id == template.id ? .white : .primary)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(complaintService.selectedTemplate?.id == template.id ? Color.orange : Color.gray.opacity(0.2))
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Generated complaint text
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("E-post til \(complaintService.selectedNewspaper?.name ?? "avisa"):")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(complaintService.generateComplaint())
                            .font(.body)
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(12)
                            .textSelection(.enabled)
                    }
                }
                
                // Share button
                Button(action: {
                    showingShareSheet = true
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Del e-post")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Sur e-post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ferdig") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ActivityView(activityItems: [complaintService.generateComplaint()])
        }
    }
}

#Preview {
    NewspaperComplaintView(
        complaintService: NewspaperComplaintService(),
        complaintText: "Test complaint"
    )
}