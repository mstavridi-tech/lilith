import SwiftUI

/// The natal chart breakdown. Every placement, plain language, Lilith placement starred.
/// Same celestial editorial language as the Today card: cosmic backdrop, hairline geometry,
/// letterspaced serif caps, mono for the ephemeris data.
struct ChartView: View {
    let chart: NatalChart
    @State private var openReading: ReadingSelection?
    @State private var showMap = false
    @State private var showPeople = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header

                if chart.risingSign == nil { missingTimeNote }

                ChartWheel(chart: chart)
                    .frame(height: 360)
                    .padding(.top, 24)

                bigThreeSection

                VStack(spacing: 0) {
                    Text("EVERY PLACEMENT").displayCaps(20, em: 0.16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 4)
                    Text("Tap any line. Every body has a story.")
                        .font(Theme.body(14)).foregroundStyle(Theme.gold.opacity(0.85))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 8)

                    ForEach(Array(chart.placements.enumerated()), id: \.element.id) { index, placement in
                        if index > 0 {
                            Rectangle().fill(Theme.gold.opacity(0.15)).frame(height: 0.5)
                        }
                        Button {
                            Haptics.open()
                            openReading = ReadingSelection(placement: placement)
                        } label: {
                            placementRow(placement)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 40)

                aspectsSection

                mapSection

                peopleSection

                transitSection

                Wordmark()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 44)
            }
            .padding(.horizontal, 28)
            .padding(.top, 16)
            .padding(.bottom, 120) // clears the floating tab bar
        }
        .scrollIndicators(.hidden)
        .auraScreen(.moonlight) // cool silver so the GOLD wheel and gold text pop (July 4: the champagne plate clashed with them, Maria)
        .sheet(item: $openReading) { ReadingSheet(selection: $0) }
        .sheet(isPresented: $showMap) { AstroMapSheet(chart: chart) }
        .sheet(isPresented: $showPeople) { PeopleSheet(chart: chart) }
    }

    // MARK: The big three — tappable, each opens its reading

    /// Sun, moon, and (if we have a birth time) rising. The placements she actually quotes.
    private var bigThree: [(part: BigThreePart, sign: ZodiacSign)] {
        var rows: [(BigThreePart, ZodiacSign)] = []
        if let s = chart.sun?.sign { rows.append((.sun, s)) }
        if let m = chart.moon?.sign { rows.append((.moon, m)) }
        if let r = chart.risingSign { rows.append((.rising, r)) }
        return rows.map { (part: $0.0, sign: $0.1) }
    }

    private var bigThreeSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("THE BIG THREE").displayCaps(20, em: 0.16)
                .padding(.bottom, 4)
            Text("Tap any one. I'll tell you about you.")
                .font(Theme.body(14)).foregroundStyle(Theme.gold.opacity(0.85))
                .padding(.bottom, 14)

            ForEach(Array(bigThree.enumerated()), id: \.offset) { index, row in
                if index > 0 {
                    Rectangle().fill(Theme.gold.opacity(0.15)).frame(height: 0.5)
                }
                Button {
                    Haptics.open()
                    openReading = .bigThree(row.part, sign: row.sign)
                } label: {
                    bigThreeRow(row.part, row.sign)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 34)
    }

    private func bigThreeRow(_ part: BigThreePart, _ sign: ZodiacSign) -> some View {
        HStack(spacing: 16) {
            Text(part.glyph)
                .font(part == .rising ? Theme.mono(11) : Theme.display(22))
                .foregroundStyle(Theme.gold)
                .frame(width: 34)
            VStack(alignment: .leading, spacing: 4) {
                Text(part.titleSuffix)
                    .font(Theme.mono(11)).tracking(Theme.tracking(11, em: 0.12))
                    .foregroundStyle(Theme.bone.opacity(0.55))
                Text(sign.name)
                    .font(Theme.body(20)).foregroundStyle(Theme.bone)
            }
            Spacer()
            Text("READ →")
                .font(Theme.mono(10)).tracking(Theme.tracking(10, em: 0.16))
                .foregroundStyle(Theme.ember)
        }
        .padding(.vertical, 16)
        .contentShape(Rectangle())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("YOUR CHART").displayCaps(34, em: 0.16)
            Text("Born \(chart.birthData.placeName). The sky kept receipts.")
                .font(Theme.body(16)).foregroundStyle(Theme.gold)
        }
    }

    private func placementRow(_ p: Placement) -> some View {
        let isLilith = p.body == .blackMoonLilith
        return HStack(alignment: .firstTextBaseline, spacing: 18) {
            Text(p.body.glyph)
                .font(Theme.display(24))
                .foregroundStyle(isLilith ? Theme.ember : Theme.gold)
                .frame(width: 34)
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text(p.body.displayName.uppercased())
                        .font(Theme.mono(12)).tracking(Theme.tracking(12, em: 0.1))
                        .foregroundStyle(Theme.bone.opacity(0.55))
                    if isLilith {
                        Text("★ THE NAMESAKE")
                            .font(Theme.mono(9.5)).tracking(Theme.tracking(9.5, em: 0.12))
                            .foregroundStyle(Theme.ember)
                    }
                }
                Text(p.formatted)
                    .font(Theme.body(18)).foregroundStyle(Theme.bone)
                if let house = p.house {
                    Text("House \(house)")
                        .font(Theme.mono(11)).foregroundStyle(Theme.gold.opacity(0.7))
                }
            }
            Spacer()
            Text("›")
                .font(Theme.display(22))
                .foregroundStyle((isLilith ? Theme.ember : Theme.gold).opacity(0.6))
        }
        .padding(.vertical, 16)
        .contentShape(Rectangle())
    }

    private var aspectsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HairlineDivider(width: 110)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 4)
            Text("MAJOR ASPECTS").displayCaps(20, em: 0.16)
            VStack(spacing: 11) {
                ForEach(chart.aspects.prefix(8)) { aspect in
                    HStack {
                        Text("\(aspect.a.glyph) \(aspect.type.rawValue) \(aspect.b.glyph)")
                            .font(Theme.body(16)).foregroundStyle(Theme.bone.opacity(0.85))
                        Spacer()
                        Text(String(format: "%.1f° orb", aspect.orb))
                            .font(Theme.mono(12)).foregroundStyle(Theme.gold.opacity(0.6))
                    }
                }
            }
        }
        .padding(.top, 36)
    }

    /// Astrocartography's front door: one row, the sheet does the work.
    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HairlineDivider(width: 110)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 4)
            Text("YOUR MAP").displayCaps(20, em: 0.16)
            Text("Where on Earth your chart hits different. Type a city, get the weather.")
                .font(Theme.body(14)).foregroundStyle(Theme.gold.opacity(0.85))
            Button {
                Haptics.open()
                showMap = true
            } label: {
                HStack {
                    Image(systemName: "globe.europe.africa")
                        .font(.system(size: 15, weight: .light))
                        .foregroundStyle(Theme.gold)
                    Text("OPEN THE MAP")
                        .font(Theme.mono(11)).tracking(Theme.tracking(11, em: 0.16))
                        .foregroundStyle(Theme.gold)
                    Spacer()
                    Text("→").font(Theme.body(18)).foregroundStyle(Theme.gold)
                }
                .padding(.horizontal, 18).padding(.vertical, 15)
                .background(Capsule().fill(.ultraThinMaterial)
                    .overlay(Capsule().strokeBorder(Theme.gold.opacity(0.35), lineWidth: 0.5)))
                .contentShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 36)
    }

    /// Compatibility's front door: the saved cast of her life, each checked against her chart.
    private var peopleSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HairlineDivider(width: 110)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 4)
            Text("YOUR PEOPLE").displayCaps(20, em: 0.16)
            Text("The bestie, the crush, the coworker. Checked against your chart, remembered forever.")
                .font(Theme.body(14)).foregroundStyle(Theme.gold.opacity(0.85))
            Button {
                Haptics.open()
                showPeople = true
            } label: {
                HStack {
                    Image(systemName: "person.2")
                        .font(.system(size: 15, weight: .light))
                        .foregroundStyle(Theme.gold)
                    Text("OPEN YOUR PEOPLE")
                        .font(Theme.mono(11)).tracking(Theme.tracking(11, em: 0.16))
                        .foregroundStyle(Theme.gold)
                    Spacer()
                    Text("→").font(Theme.body(18)).foregroundStyle(Theme.gold)
                }
                .padding(.horizontal, 18).padding(.vertical, 15)
                .background(Capsule().fill(.ultraThinMaterial)
                    .overlay(Capsule().strokeBorder(Theme.gold.opacity(0.35), lineWidth: 0.5)))
                .contentShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 36)
    }

    /// The full live-sky feed (Today shows the top 3; this is everything hitting her chart now).
    private var transitSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HairlineDivider(width: 110)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 4)
            Text("THE SKY RIGHT NOW").displayCaps(20, em: 0.16)
            Text("Live, against your chart. This is why today feels like today.")
                .font(Theme.body(14)).foregroundStyle(Theme.gold.opacity(0.85))
            TransitFeed(transits: TransitEngine.current(for: chart))
        }
        .padding(.top, 36)
    }

    private var missingTimeNote: some View {
        Text("No birth time means no rising sign or houses. Your mother knows. Ask her, then update in settings.")
            .font(Theme.body(15)).foregroundStyle(Theme.ember)
            .lineSpacing(4)
            .padding(.vertical, 18)
            .padding(.horizontal, 18)
            .overlay(
                Rectangle().fill(Theme.ember.opacity(0.5)).frame(width: 0.5),
                alignment: .leading)
            .padding(.top, 24)
    }
}
