//
//  SOSLocalShare.swift
//  Map_iOS
//
//  Condivisione locale della posizione SENZA backend:
//  - SMS (MFMessageComposeViewController) con destinatari dai contatti salvati
//  - WhatsApp / Telegram via deeplink (aprono l’app con testo precompilato)
//  - Share Sheet di sistema come fallback
//
//  Requisiti:
//  - Info.plist: NSLocationWhenInUseUsageDescription (e Always consigliato)
//  - Info.plist: LSApplicationQueriesSchemes -> whatsapp, tg (per canOpenURL)
//  - MessageUI.framework (SMS)
//

import Foundation
import SwiftUI
import CoreLocation
import MessageUI
import UIKit

// MARK: - Helper link mappa

struct SOSLinkBuilder {
    static func googleMapsLink(lat: Double, lon: Double) -> String {
        let latStr = String(format: "%.5f", lat)
        let lonStr = String(format: "%.5f", lon)
        return "https://maps.google.com/?q=\(latStr),\(lonStr)"
    }
    static func appleMapsLink(lat: Double, lon: Double) -> String {
        let latStr = String(format: "%.5f", lat)
        let lonStr = String(format: "%.5f", lon)
        return "https://maps.apple.com/?ll=\(latStr),\(lonStr)&q=SOS"
    }
}







// MARK: - Dispatcher locale (senza backend)

enum SOSLocalError: Error {
    case noContacts
    case noLocation
    case cannotOpenApp(String)
}

final class SOSLocalDispatcher: NSObject {
    static let shared = SOSLocalDispatcher()

    private let locationManager = CLLocationManager()
    private var locationCallback: ((Result<CLLocationCoordinate2D, SOSLocalError>) -> Void)?

    // MARK: Public APIs

    /// Prepara SMS con contatti salvati + link posizione. La UI (sheet) la presenti tu.
    /// Esempio d'uso: dispatcher.composeSMS(note:) { recipients, body in ... show sheet ... }
    func composeSMS(note: String? = nil,
                    preferAppleMaps: Bool = false,
                    completion: @escaping (Result<(recipients: [String], body: String), SOSLocalError>) -> Void) {

        let recipients = readContacts()
        guard !recipients.isEmpty else {
            completion(.failure(.noContacts)); return
        }

        requestWhenInUseIfNeeded()

        oneShotLocation { result in
            switch result {
            case .failure(let e):
                completion(.failure(e))
            case .success(let coord):
                let link = preferAppleMaps
                ? SOSLinkBuilder.appleMapsLink(lat: coord.latitude, lon: coord.longitude)
                : SOSLinkBuilder.googleMapsLink(lat: coord.latitude, lon: coord.longitude)

                var body = "[SOS] Posizione: \(link)"
                if let note, !note.isEmpty { body += "\n\(note)" }
                completion(.success((recipients, body)))
            }
        }
    }

    /// Apre WhatsApp con messaggio già pronto. Se passi phoneE164, apre direttamente quella chat.
    /// Altrimenti apre il chooser di WhatsApp.
    func openWhatsApp(note: String? = nil,
                      preferAppleMaps: Bool = false,
                      phoneE164: String? = nil,
                      onError: @escaping (SOSLocalError) -> Void) {

        requestWhenInUseIfNeeded()
        oneShotLocation { res in
            switch res {
            case .failure(let e): onError(e)
            case .success(let c):
                let link = preferAppleMaps
                ? SOSLinkBuilder.appleMapsLink(lat: c.latitude, lon: c.longitude)
                : SOSLinkBuilder.googleMapsLink(lat: c.latitude, lon: c.longitude)
                var text = "[SOS] Position: \(link)"
                if let note, !note.isEmpty { text += "\n\(note)" }

                guard let encoded = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                    onError(.cannotOpenApp("Encoding URL"))
                    return
                }

                let urlStr: String
                if let phone = phoneE164, !phone.isEmpty {
                    urlStr = "whatsapp://send?phone=\(phone)&text=\(encoded)"
                } else {
                    urlStr = "whatsapp://send?text=\(encoded)"
                }
                guard let url = URL(string: urlStr),
                      UIApplication.shared.canOpenURL(url) else {
                    onError(.cannotOpenApp("WhatsApp is not available"))
                    return
                }
                UIApplication.shared.open(url)
            }
        }
    }

    /// Apre Telegram con testo/link precompilati (chooser). In alternativa puoi usare tg://resolve?domain=@username.
    func openTelegram(note: String? = nil,
                      preferAppleMaps: Bool = false,
                      onError: @escaping (SOSLocalError) -> Void) {

        requestWhenInUseIfNeeded()
        oneShotLocation { res in
            switch res {
            case .failure(let e): onError(e)
            case .success(let c):
                let link = preferAppleMaps
                ? SOSLinkBuilder.appleMapsLink(lat: c.latitude, lon: c.longitude)
                : SOSLinkBuilder.googleMapsLink(lat: c.latitude, lon: c.longitude)
                var text = "[SOS] Position"
                if let note, !note.isEmpty { text += " — \(note)" }

                // Usa lo schema HTTP (t.me/share/url) per massima compatibilità
                var comps = URLComponents(string: "https://t.me/share/url")!
                comps.queryItems = [
                    .init(name: "url", value: link),
                    .init(name: "text", value: text)
                ]
                guard let url = comps.url, UIApplication.shared.canOpenURL(url) else {
                    onError(.cannotOpenApp("Telegram is not available"))
                    return
                }
                UIApplication.shared.open(url)
            }
        }
    }

    // MARK: - Interni

    private func readContacts() -> [String] {
        if let data = UserDefaults.standard.data(forKey: "contacts"),
           let list = try? JSONDecoder().decode([Contatto].self, from: data) {
            return list.map(\.telefono)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }
        return []
    }

    private func requestWhenInUseIfNeeded() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }

    private func oneShotLocation(completion: @escaping (Result<CLLocationCoordinate2D, SOSLocalError>) -> Void) {
        locationCallback = completion
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestLocation()
    }
}

extension SOSLocalDispatcher: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let c = locations.last?.coordinate {
            locationCallback?(.success(c))
        } else {
            locationCallback?(.failure(.noLocation))
        }
        locationCallback = nil
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationCallback?(.failure(.noLocation))
        locationCallback = nil
    }
}
