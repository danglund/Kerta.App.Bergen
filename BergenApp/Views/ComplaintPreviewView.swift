import SwiftUI
import MessageUI

struct ComplaintPreviewView: View {
    @ObservedObject var complaintService: NewspaperComplaintService
    @Environment(\.dismiss) private var dismiss
    @State private var currentTemplateIndex = 0
    @State private var showingMailComposer = false
    @State private var showingNoMailAlert = false
    
    var availableTemplates: [ComplaintTemplate] {
        complaintService.availableTemplates
    }
    
    var currentTemplate: ComplaintTemplate? {
        guard !availableTemplates.isEmpty,
              currentTemplateIndex < availableTemplates.count else { return nil }
        return availableTemplates[currentTemplateIndex]
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Newspaper selector
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
                
                // Template navigation
                if availableTemplates.count > 1 {
                    HStack {
                        Button(action: {
                            if currentTemplateIndex > 0 {
                                currentTemplateIndex -= 1
                            }
                        }) {
                            Image(systemName: "chevron.left.circle.fill")
                                .font(.title2)
                                .foregroundColor(currentTemplateIndex > 0 ? .blue : .gray)
                        }
                        .disabled(currentTemplateIndex == 0)
                        
                        Spacer()
                        
                        Text("\(currentTemplateIndex + 1) av \(availableTemplates.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button(action: {
                            if currentTemplateIndex < availableTemplates.count - 1 {
                                currentTemplateIndex += 1
                            }
                        }) {
                            Image(systemName: "chevron.right.circle.fill")
                                .font(.title2)
                                .foregroundColor(currentTemplateIndex < availableTemplates.count - 1 ? .blue : .gray)
                        }
                        .disabled(currentTemplateIndex >= availableTemplates.count - 1)
                    }
                    .padding(.horizontal)
                }
                
                // Complaint preview
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        if let template = currentTemplate {
                            Text(template.title)
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text(generateComplaintText())
                                .font(.body)
                                .padding()
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(12)
                                .textSelection(.enabled)
                        } else {
                            Text("Ingen malar tilgjengelege")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Send button
                Button(action: {
                    if MFMailComposeViewController.canSendMail() {
                        showingMailComposer = true
                    } else {
                        showingNoMailAlert = true
                    }
                }) {
                    HStack {
                        Image(systemName: "envelope.fill")
                        Text("Send e-post")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .disabled(currentTemplate == nil || complaintService.selectedNewspaper == nil)
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
        .sheet(isPresented: $showingMailComposer) {
            if let newspaper = complaintService.selectedNewspaper,
               let template = currentTemplate {
                MailComposeView(
                    recipients: [newspaper.email],
                    subject: template.title,
                    messageBody: generateComplaintText()
                )
            }
        }
        .alert("Kan ikkje senda e-post", isPresented: $showingNoMailAlert) {
            Button("OK") { }
        } message: {
            Text("E-post er ikkje konfigurert på denne eininga.")
        }
        .onAppear {
            // Ensure VG is selected by default
            if complaintService.selectedNewspaper == nil {
                if let vg = complaintService.newspapers.first(where: { $0.id == "vg" }) {
                    complaintService.selectNewspaper(vg)
                } else if let firstNewspaper = complaintService.newspapers.first {
                    complaintService.selectNewspaper(firstNewspaper)
                }
            }
        }
    }
    
    private func generateComplaintText() -> String {
        guard let template = currentTemplate,
              let newspaper = complaintService.selectedNewspaper else {
            return "Ingen mal eller avis valgt"
        }
        
        var complaintText = template.text
        
        // Replace placeholders with actual newspaper name
        for (placeholder, _) in template.placeholders {
            complaintText = complaintText.replacingOccurrences(of: "[\(placeholder)]", with: newspaper.name)
        }
        
        return complaintText
    }
}

// Mail composer wrapper
struct MailComposeView: UIViewControllerRepresentable {
    let recipients: [String]
    let subject: String
    let messageBody: String
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        composer.setToRecipients(recipients)
        composer.setSubject(subject)
        composer.setMessageBody(messageBody, isHTML: false)
        return composer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposeView
        
        init(_ parent: MailComposeView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.dismiss()
        }
    }
}

#Preview {
    ComplaintPreviewView(complaintService: NewspaperComplaintService())
}