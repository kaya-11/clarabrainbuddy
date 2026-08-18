//
//  Services/TaskSplitter/TaskDomain.swift
//  ClaraBrainBuddy
//
//  Created by Karen on 18.08.26.
//

@available(iOS 26.0, *)
enum TaskDomain: String, CaseIterable, Identifiable {
    case administration = "Administration"
    case haushalt = "Haushalt"
    case garten = "Garten"
    case renovierung = "Renovierung"
    case technik = "Technik"
    case sonstiges = "Sonstiges"

    var id: String { rawValue }

    /// Ein vollständiges Beispiel pro Domain – inklusive Zahlenwerten,
    var fewShotExample: String {
        switch self {
        case .administration:
            return """
            Beispiel – Aufgabe "Steuererklärung machen":
            1. "Steuerprogramm installieren und öffnen" | 15 Min | Widerstand 6 | Energie -1
            2. "Belege und Dokumente an einen Ort sammeln" | 20 Min | Widerstand 7 | Energie -1
            3. "Daten vom Vorjahr übernehmen" | 10 Min | Widerstand 3 | Energie 0
            4. "Daten von Elster abholen" | 25 Min | Widerstand 5 | Energie -1
            5. "Einkünfte eintragen" | 25 Min | Widerstand 5 | Energie -1
            6. "Ausgaben und Belege eintragen" | 30 Min | Widerstand 6 | Energie -1
            7. "Alles prüfen und abschicken" | 15 Min | Widerstand 4 | Energie 1
            """
        case .haushalt:
            return """
            Beispiel – Aufgabe "Küche aufräumen":
            1. "Musik anmachen" | 5 Min | Widerstand 2 | Energie 1
            2. "Geschirr in die Spülmaschine räumen" | 10 Min | Widerstand 4 | Energie -1
            3. "Spülmaschine anschmeißen" | 5 Min | Widerstand 0 | Energie 1
            4. "Arbeitsflächen freiräumen und abwischen" | 15 Min | Widerstand 3 | Energie 0
            5. "Müll rausbringen" | 5 Min | Widerstand 3 | Energie 0
            6. "Boden fegen" | 10 Min | Widerstand 2 | Energie 0
            """
        case .garten:
            return """
            Beispiel – Aufgabe "Beet für den Frühling vorbereiten":
            1. "Gartenhandschuhe und Werkzeug rauslegen" | 5 Min | Widerstand 2 | Energie 0
            2. "Unkraut aus dem Beet entfernen" | 30 Min | Widerstand 5 | Energie -1
            3. "Boden auflockern" | 20 Min | Widerstand 3 | Energie 0
            4. "Kompost einarbeiten" | 15 Min | Widerstand 3 | Energie 0
            5. "Werkzeug wegräumen und Hände waschen" | 10 Min | Widerstand 1 | Energie 1
            Beispiel – Aufgabe "Rasen mähen":
            1. "Rasenmäher holen" | 10 Min | Widerstand 5 | Energie 0
            2. "Rasen mähen" | 30 Min | Widerstand 2 | Energie 0
            3. "Rasenmäher wegräumen" | 10 Min | Widerstand 1 | Energie 1
            """
        case .renovierung:
            return """
            Beispiel – Aufgabe "Wohnzimmer streichen":
            1. "Farbe, Rollen und Abdeckfolie besorgen" | 45 Min | Widerstand 4 | Energie 0
            2. "Möbel in die Mitte rücken und abdecken" | 20 Min | Widerstand 5 | Energie -1
            3. "Kanten und Steckdosen abkleben" | 30 Min | Widerstand 6 | Energie -1
            4. "Erste Wand streichen" | 30 Min | Widerstand 4 | Energie 0
            5. "Weitere Wand streichen" | 30 Min | Widerstand 3 | Energie 1
            6. "Restliche Wände streichen" | 45 Min | Widerstand 3 | Energie -1
            7. "Klebeband abziehen und aufräumen" | 20 Min | Widerstand 2 | Energie -1
            """
        case .technik:
            return """
            Beispiel – Aufgabe "Router ins Arbeitszimmer umziehen":
            1. "Neuen Standort und Kabelweg festlegen" | 15 Min | Widerstand 3 | Energie 0
            2. "Kabellänge messen und LAN-Kabel besorgen" | 30 Min | Widerstand 4 | Energie 0
            3. "Kabel entlang der Leiste verlegen" | 45 Min | Widerstand 6 | Energie -1
            4. "Router abbauen und am neuen Ort anschließen" | 15 Min | Widerstand 3 | Energie 0
            5. "Prüfen, ob Internet und WLAN funktionieren" | 10 Min | Widerstand 2 | Energie 0
            6. "Geräte neu verbinden und Empfang testen" | 15 Min | Widerstand 2 | Energie 1
            """
        case .sonstiges:
            return """
            Beispiel – Aufgabe "Zahnarzttermin organisieren":
            1. "Telefonnummer der Praxis raussuchen" | 5 Min | Widerstand 3 | Energie 0
            2. "Anrufen und Termin vereinbaren" | 10 Min | Widerstand 7 | Energie -1
            3. "Termin in den Kalender eintragen" | 5 Min | Widerstand 1 | Energie 1
            """
        }
    }
}
