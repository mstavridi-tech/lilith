import SwiftUI
import Combine

// MARK: - YOUR PEOPLE (July 5, Maria's spec: compatibility she can save, per person, per role)
//
// Phase 3's compatibility, opened by Maria's direct request. She adds a person once (name, what
// they are to her, birthday), the app computes the synastry against HER chart and remembers them
// forever, on-device like everything. This store is deliberately the future chatbot's memory:
// when chat ships and she types "Eleni is being weird", the bot looks Eleni up right here and
// already knows she's the coworker with the spicy Mars. Birthday-level astrology, honestly
// labelled: real charts need a birth time, and the card says which kind it's reading from.

/// What this person is to her. The chatbot inherits these labels as context.
enum Relationship: String, Codable, CaseIterable, Identifiable {
    case bestie, lover, crush, situationship, coworker, boss, family, roommate, ex

    var id: String { rawValue }
    var label: String { rawValue.uppercased() }
}

struct Person: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var role: Relationship
    var year: Int
    var month: Int
    var day: Int

    var birthComponents: DateComponents {
        DateComponents(year: year, month: month, day: day)
    }
}

/// On-device, same pattern as every other store. Never leaves the phone.
final class PeopleStore: ObservableObject {
    static let shared = PeopleStore()

    @Published private(set) var people: [Person] = []

    private let key = "lilith.people"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Person].self, from: data) {
            people = decoded
        }
    }

    func add(_ person: Person) {
        people.append(person)
        persist()
    }

    func delete(_ person: Person) {
        people.removeAll { $0.id == person.id }
        persist()
    }

    func deleteAll() {
        people = []
        UserDefaults.standard.removeObject(forKey: key)
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(people) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

// MARK: - The synastry math (transparent, birthday-level, on-device)

enum Synastry {
    /// Their noon-UTC chart from a birthday alone. Sun, Venus, Mars are solid at this precision;
    /// the Moon can be off when someone's born near a sign boundary, and we say so in the UI.
    static func chart(for person: Person) -> NatalChart? {
        let birth = BirthData(date: person.birthComponents, time: nil, placeName: "",
                              latitude: 0, longitude: 0, timeZoneID: "UTC")
        return try? ChartEngine.natalChart(for: birth)
    }

    private static func element(_ sign: ZodiacSign) -> Int { sign.rawValue % 4 } // fire earth air water

    /// 0...100, from sun-element chemistry plus the cross-aspects between the loud four
    /// (sun, moon, venus, mars) of both charts. Simple, explainable, consistent.
    static func score(hers: NatalChart, theirs: NatalChart) -> Int {
        guard let herSun = hers.sun, let theirSun = theirs.sun else { return 50 }

        let e1 = element(herSun.sign), e2 = element(theirSun.sign)
        var score: Double
        switch (e1, e2) {
        case let (a, b) where a == b: score = 78                       // same element: instant shorthand
        case (0, 2), (2, 0), (1, 3), (3, 1): score = 86                // fire+air, earth+water: the classics
        case (0, 3), (3, 0), (1, 2), (2, 1): score = 58                // fire+water, earth+air: steam and dust
        default: score = 66                                            // fire+earth, air+water: workable
        }

        let loudFour: [CelestialBody] = [.sun, .moon, .venus, .mars]
        let herPlacements = hers.placements.filter { loudFour.contains($0.body) }
        let theirPlacements = theirs.placements.filter { loudFour.contains($0.body) }
        for h in herPlacements {
            for t in theirPlacements {
                let d = abs((h.longitude - t.longitude).truncatingRemainder(dividingBy: 360))
                let sep = d > 180 ? 360 - d : d
                if [0.0, 60, 120].contains(where: { abs(sep - $0) <= 6 }) { score += 2.5 }
                if [90.0, 180].contains(where: { abs(sep - $0) <= 6 }) { score -= 1.5 }
            }
        }
        return Int(min(97, max(25, score)))
    }

    /// The verdict, in voice, flavored by what they are to her.
    static func reading(score: Int, role: Relationship, name: String,
                        herSun: ZodiacSign, theirSun: ZodiacSign) -> String {
        let band: String
        switch score {
        case 85...: band = "Written in the stars, honestly a little disgusting. \(theirSun.name) and your \(herSun.name) just work."
        case 70..<85: band = "Easy chemistry. \(theirSun.name) meets your \(herSun.name) without either of you performing."
        case 55..<70: band = "Workable, with communication. \(theirSun.name) and \(herSun.name) speak different dialects of the same language."
        default: band = "Spicy. \(theirSun.name) against your \(herSun.name) is friction, and friction is growth you didn't order."
        }
        let flavor: String
        switch role {
        case .lover: flavor = "For a love like this, lead with the honesty; the chart handles the sparks."
        case .crush: flavor = "As a crush? The math says shoot the shot and report back."
        case .situationship: flavor = "For a situationship, this either gets a title or gets closure. The stars vote for deciding."
        case .bestie: flavor = "Bestie material confirmed. Protect this one."
        case .roommate: flavor = "As roommates, agree on the dishes early and this works."
        case .coworker: flavor = "Keep it professional and this energy actually gets things shipped."
        case .boss: flavor = "Manage the vibe, not just the tasks, and this boss is handleable."
        case .family: flavor = "Family is forever, so consider this the user manual, not a verdict."
        case .ex: flavor = "And girl... why are we checking. Okay. For research. Noted."
        }
        return band + " " + flavor
    }
}

// MARK: - The people sheet

struct PeopleSheet: View {
    let chart: NatalChart
    @ObservedObject private var store = PeopleStore.shared
    @Environment(\.dismiss) private var dismiss
    @State private var adding = false
    @State private var reading: Person?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("YOUR PEOPLE")
                    .displayCaps(26, em: 0.14)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.leading, Theme.tracking(26, em: 0.14))
                    .padding(.top, 44)
                Text("The cast of your life, checked against your chart.")
                    .font(Theme.body(15).italic()).foregroundStyle(Theme.gold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)

                HairlineDivider(width: 120)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 22)

                if store.people.isEmpty {
                    Text("Nobody in the file yet. Add the bestie, the crush, the coworker who tests you. I remember everyone, and when the chat arrives I'll already know exactly who you mean.")
                        .font(Theme.body(15)).foregroundStyle(Theme.bone.opacity(0.85))
                        .lineSpacing(6)
                        .padding(.top, 28)
                } else {
                    ForEach(store.people) { person in
                        if person.id != store.people.first?.id {
                            Rectangle().fill(Theme.gold.opacity(0.12)).frame(height: 0.5)
                        }
                        personRow(person)
                    }
                    .padding(.top, 10)
                }

                Button {
                    Haptics.open(); adding = true
                } label: {
                    Text("ADD SOMEONE")
                        .font(Theme.mono(12)).tracking(Theme.tracking(12, em: 0.18))
                        .foregroundStyle(Theme.void)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Capsule().fill(Theme.gold))
                        .background(Capsule().fill(Theme.gold).opacity(0.4).blur(radius: 18))
                }
                .buttonStyle(.plain)
                .padding(.top, 30)

                Text("Birthday-level readings: sun, Venus, Mars, the loud parts. Names and birthdays stay on this phone.")
                    .font(Theme.body(12).italic()).foregroundStyle(Theme.gold.opacity(0.65))
                    .padding(.top, 16)

                Wordmark()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 40)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .glassSheet(glyph: "✶", accent: Theme.gold)
        .overlay(alignment: .topTrailing) {
            Button { dismiss() } label: {
                Text("CLOSE")
                    .font(Theme.mono(11)).tracking(Theme.tracking(11, em: 0.18))
                    .foregroundStyle(Theme.gold.opacity(0.75))
                    .padding(20)
            }
        }
        .sheet(isPresented: $adding) { AddPersonSheet(store: store) }
        .sheet(item: $reading) { PersonReadingSheet(person: $0, chart: chart, store: store) }
    }

    private func personRow(_ person: Person) -> some View {
        let their = Synastry.chart(for: person)
        let score = their.map { Synastry.score(hers: chart, theirs: $0) }
        return Button {
            Haptics.open(); reading = person
        } label: {
            HStack(spacing: 14) {
                scoreRing(score)
                VStack(alignment: .leading, spacing: 4) {
                    Text(person.name)
                        .font(Theme.body(17)).foregroundStyle(Theme.bone)
                    HStack(spacing: 8) {
                        Text(person.role.label)
                            .font(Theme.mono(8.5)).tracking(Theme.tracking(8.5, em: 0.16))
                            .foregroundStyle(Theme.ember)
                        if let sun = their?.sun?.sign {
                            Text(sun.name.uppercased())
                                .font(Theme.mono(8.5)).tracking(Theme.tracking(8.5, em: 0.16))
                                .foregroundStyle(Theme.gold.opacity(0.7))
                        }
                    }
                }
                Spacer()
                Text("→").font(Theme.body(18)).foregroundStyle(Theme.gold)
            }
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func scoreRing(_ score: Int?) -> some View {
        ZStack {
            Circle().stroke(Theme.bone.opacity(0.12), lineWidth: 3)
            if let score {
                Circle()
                    .trim(from: 0, to: Double(score) / 100)
                    .stroke(Theme.gold, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(score)")
                    .font(Theme.data(14)).foregroundStyle(Theme.bone)
            }
        }
        .frame(width: 44, height: 44)
    }
}

// MARK: - Adding someone

struct AddPersonSheet: View {
    let store: PeopleStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var role: Relationship = .bestie
    @State private var birthday = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("ADD SOMEONE")
                    .displayCaps(24, em: 0.14)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.leading, Theme.tracking(24, em: 0.14))
                    .padding(.top, 44)

                HairlineDivider(width: 120)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 22)

                fieldLabel("THEIR NAME")
                TextField("what you actually call them", text: $name)
                    .font(Theme.body(16)).foregroundStyle(Theme.bone)
                    .tint(Theme.gold)
                    .autocorrectionDisabled()
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Theme.bone.opacity(0.05))
                            .overlay(RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(Theme.gold.opacity(0.25), lineWidth: 0.5))
                    )

                fieldLabel("WHAT THEY ARE TO YOU")
                FlowLayout(spacing: 9) {
                    ForEach(Relationship.allCases) { r in
                        Button {
                            Haptics.light(); role = r
                        } label: {
                            LuxChip(label: r.label, on: role == r, accent: Theme.ember)
                        }
                        .buttonStyle(.plain)
                    }
                }

                fieldLabel("THEIR BIRTHDAY")
                DatePicker("", selection: $birthday, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .colorScheme(.dark)
                    .frame(maxWidth: .infinity)

                Button {
                    Haptics.soft()
                    let c = Calendar.current.dateComponents([.year, .month, .day], from: birthday)
                    store.add(Person(name: name.trimmingCharacters(in: .whitespaces),
                                     role: role,
                                     year: c.year ?? 2000, month: c.month ?? 1, day: c.day ?? 1))
                    dismiss()
                } label: {
                    Text("SAVE THEM")
                        .font(Theme.mono(12)).tracking(Theme.tracking(12, em: 0.2))
                        .foregroundStyle(Theme.void)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Capsule().fill(Theme.gold))
                        .background(Capsule().fill(Theme.gold).opacity(0.4).blur(radius: 18))
                }
                .buttonStyle(.plain)
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(name.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
                .padding(.top, 26)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .glassSheet(glyph: "", accent: Theme.gold)
        .overlay(alignment: .topTrailing) {
            Button { dismiss() } label: {
                Text("CLOSE")
                    .font(Theme.mono(11)).tracking(Theme.tracking(11, em: 0.18))
                    .foregroundStyle(Theme.gold.opacity(0.75))
                    .padding(20)
            }
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(Theme.mono(10)).tracking(Theme.tracking(10, em: 0.26))
            .foregroundStyle(Theme.ember)
            .padding(.top, 26)
            .padding(.bottom, 10)
    }
}

// MARK: - One person's reading

struct PersonReadingSheet: View {
    let person: Person
    let chart: NatalChart
    let store: PeopleStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let their = Synastry.chart(for: person)
        let score = their.map { Synastry.score(hers: chart, theirs: $0) }

        return ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(person.name.uppercased())
                    .displayCaps(26, em: 0.14)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.leading, Theme.tracking(26, em: 0.14))
                    .padding(.top, 44)
                Text(person.role.label.lowercased())
                    .font(Theme.body(15).italic()).foregroundStyle(Theme.gold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)

                HairlineDivider(width: 120)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 22)

                if let their, let score, let herSun = chart.sun?.sign, let theirSun = their.sun?.sign {
                    VStack(spacing: 10) {
                        Text("\(score)")
                            .font(Theme.data(64)).foregroundStyle(Theme.bone)
                        Text("OF 100, WITH YOU")
                            .font(Theme.mono(9)).tracking(Theme.tracking(9, em: 0.26))
                            .foregroundStyle(Theme.gold.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 30)
                    .shadow(color: .black.opacity(0.4), radius: 10, y: 2)

                    Text(Synastry.reading(score: score, role: person.role, name: person.name,
                                          herSun: herSun, theirSun: theirSun))
                        .font(Theme.body(16)).foregroundStyle(Theme.bone.opacity(0.9))
                        .lineSpacing(7)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 26)

                    Text("Read from their birthday: sun in \(theirSun.name), Venus and Mars in play. A birth time would sharpen the moon and the whole picture.")
                        .font(Theme.body(12).italic()).foregroundStyle(Theme.gold.opacity(0.65))
                        .padding(.top, 18)
                } else {
                    Text("Couldn't compute this one. Check the birthday and try again.")
                        .font(Theme.body(15)).foregroundStyle(Theme.ember)
                        .padding(.top, 28)
                }

                Button {
                    Haptics.light()
                    store.delete(person)
                    dismiss()
                } label: {
                    Text("REMOVE FROM YOUR PEOPLE")
                        .font(Theme.mono(10)).tracking(Theme.tracking(10, em: 0.14))
                        .foregroundStyle(Theme.blood.opacity(0.85))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .overlay(Capsule().strokeBorder(Theme.blood.opacity(0.4), lineWidth: 0.5))
                }
                .buttonStyle(.plain)
                .padding(.top, 34)

                Wordmark()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 40)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .glassSheet(glyph: "✶", accent: Theme.gold)
        .overlay(alignment: .topTrailing) {
            Button { dismiss() } label: {
                Text("CLOSE")
                    .font(Theme.mono(11)).tracking(Theme.tracking(11, em: 0.18))
                    .foregroundStyle(Theme.gold.opacity(0.75))
                    .padding(20)
            }
        }
    }
}
