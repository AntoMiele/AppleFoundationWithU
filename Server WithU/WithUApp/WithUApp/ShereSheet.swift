import SwiftUI
import UIKit

/// Simple wrapper for UIActivityViewController to share text, links, etc.
/// Used as a fallback when the device cannot send SMS (no SIM / iMessage not active).
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}


/*/// 
 struct ShareSheet: UIViewControllerRepresentable {
     let items: [Any]
     func makeUIViewController(context: Context) -> UIActivityViewController {
         UIActivityViewController(activityItems: items, applicationActivities: nil)
     }
     func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
 }*/
