import Foundation
import Combine

enum AppPhase {
    case home
    case pack
    case names
    case distribution
    case revealImpostor
    case done
}

enum RoundMode: String, CaseIterable {
    case players
    case clubs

    var label: String {
        switch self {
        case .players: return "Joueurs"
        case .clubs: return "Clubs"
        }
    }

    var typeTag: String {
        switch self {
        case .players: return "player"
        case .clubs: return "club"
        }
    }
}

@MainActor
final class GameState: ObservableObject {

    private let playersStorageKey = "varimpostor.savedPlayers"
    private let packKey = "varimpostor.selectedPackID"
    private let impostorKey = "varimpostor.impostorCount"

    @Published var phase: AppPhase = .home

    // Players (PERSISTED)
    @Published var players: [Player] = [] {
        didSet { savePlayers() }
    }

    @Published var currentIndex: Int = 0
    @Published var round: Int = 1
    @Published var selectedPackID: String = "football" {
        didSet { UserDefaults.standard.set(selectedPackID, forKey: packKey) }
    }
    @Published var impostorCount: Int = 1 {
        didSet { UserDefaults.standard.set(impostorCount, forKey: impostorKey) }
    }

    // ✅ REMOVED: difficulty system

    // ✅ Round mode (no more random type mixing)
    @Published var roundMode: RoundMode = .players

    @Published private(set) var normalWord: String = "—"
    @Published private(set) var impostorWord: String = "—"
    @Published private(set) var categoryTitle: String = ""

    @Published private(set) var impostorIndices: Set<Int> = []

    // Anti repetition
    private var usedCombos: Set<String> = []

    init() {
        loadPlayers()

        if let savedPack = UserDefaults.standard.string(forKey: packKey) {
            selectedPackID = savedPack
        }
        let savedImp = UserDefaults.standard.integer(forKey: impostorKey)
        if savedImp > 0 { impostorCount = savedImp }
    }

    private func savePlayers() {
        let names = players.map { $0.name }
        UserDefaults.standard.set(names, forKey: playersStorageKey)
    }

    private func loadPlayers() {
        guard let saved = UserDefaults.standard.array(forKey: playersStorageKey) as? [String] else { return }
        players = saved.map { Player(name: $0) }
    }

    var playersCount: Int { players.count }

    var selectedPackLabel: String {
        switch selectedPackID {
        case "football": return "Football"
        default: return selectedPackID.capitalized
        }
    }

    var impostorNames: [String] {
        let indices = impostorIndices.sorted()
        return indices.compactMap { idx in
            guard players.indices.contains(idx) else { return nil }
            return players[idx].name
        }
    }

    // MARK: - Pack availability checks (for UI / gating)

    /// Count items for a given type in the selected pack (no more pop filter)
    func availableItemCount(for mode: RoundMode) -> Int {
        guard let pack = PacksStore.shared.pack(id: selectedPackID) else { return 0 }
        let allItems = pack.categories.flatMap { $0.items }
        return allItems.filter { $0.tags.contains("type:\(mode.typeTag)") }.count
    }

    /// For Clubs mode, if you have too few clubs, it becomes repetitive.
    var clubsModeIsHealthy: Bool {
        availableItemCount(for: .clubs) >= 10
    }

    // MARK: - Flow

    func startNewGame() {
        round = 1
        players = []
        currentIndex = 0
        impostorIndices = []
        normalWord = "—"
        impostorWord = "—"
        categoryTitle = ""
        usedCombos.removeAll()
        phase = .names
    }

    func prepareNewSessionKeepingPlayers() {
        round = 1
        currentIndex = 0
        impostorIndices = []
        normalWord = "—"
        impostorWord = "—"
        categoryTitle = ""
        usedCombos.removeAll()
    }

    func backToHome() { phase = .home }
    func goToDone() { phase = .done }

    func nextRound() {
        round += 1
        currentIndex = 0
        impostorIndices = []
        beginDistribution()
    }

    // MARK: - Distribution

    func beginDistribution() {
        guard players.count >= 3 else { return }

        // Safety: if user picked Clubs but pack is too small, force players
        if roundMode == .clubs, !clubsModeIsHealthy {
            roundMode = .players
        }

        // Pick impostors (supports 1 or more, capped to players.count - 1)
        impostorIndices.removeAll()
        let maxImpostors = max(1, min(impostorCount, max(1, players.count - 1)))
        while impostorIndices.count < maxImpostors {
            impostorIndices.insert(Int.random(in: 0..<players.count))
        }

        generateRoundWords()

        currentIndex = 0
        phase = .distribution
    }

    func wordForPlayer(at index: Int) -> String {
        return impostorIndices.contains(index) ? impostorWord : normalWord
    }

    func markRevealedAndAdvance() {
        if currentIndex < players.count - 1 {
            currentIndex += 1
        } else {
            phase = .revealImpostor
        }
    }

    // MARK: - Word Generation (MODE-LOCKED, NO POP FILTER, MORE TAG VARIETY)

    private func generateRoundWords() {
        guard let pack = PacksStore.shared.pack(id: selectedPackID) else {
            normalWord = "—"; impostorWord = "—"; categoryTitle = ""
            return
        }

        let allItems = pack.categories.flatMap { $0.items }
        guard allItems.count >= 2 else {
            normalWord = "—"; impostorWord = "—"; categoryTitle = ""
            return
        }

        // ✅ REMOVED: Pop filter (no more difficulty)
        let baseItems = allItems

        // Use ONLY the selected mode type
        let roundType = roundMode.typeTag
        let typedItems = baseItems.filter { $0.tags.contains("type:\(roundType)") }
        guard typedItems.count >= 2 else {
            fallbackTwoRandomWords(from: baseItems.map { $0.text })
            categoryTitle = roundMode.label
            return
        }

        // Build tag -> [items] inside this type (pairing logic)
        var tagMap: [String: [WordItemJSON]] = [:]
        for item in typedItems {
            let tags = allowedPairTags(from: item.tags)
            for tag in tags {
                tagMap[tag, default: []].append(item)
            }
        }

        let validTags = tagMap.keys.filter { (tagMap[$0]?.count ?? 0) >= 2 }
        guard !validTags.isEmpty else {
            fallbackTwoRandomWords(from: typedItems.map { $0.text })
            categoryTitle = roundMode.label
            return
        }

        // ✅ IMPROVED: Prioritize non-nationality tags for more variety
        let nonNationalityTags = validTags.filter { tag in
            !isNationalityTag(tag)
        }
        
        // If we have non-nationality options, prefer those 70% of the time
        let tagsToUse: [String]
        if !nonNationalityTags.isEmpty && Double.random(in: 0...1) < 0.7 {
            tagsToUse = nonNationalityTags
        } else {
            tagsToUse = Array(validTags)
        }

        // Pick a tag + pair, avoid repeats
        for _ in 0..<80 {
            guard let tag = tagsToUse.randomElement(),
                  var candidates = tagMap[tag], candidates.count >= 2 else { continue }

            candidates.shuffle()

            let a = candidates[0].text
            var b = candidates[1].text
            var i = 1
            while b == a && i < candidates.count - 1 {
                i += 1
                b = candidates[i].text
            }
            guard a != b else { continue }

            let normal = Bool.random() ? a : b
            let imp = (normal == a) ? b : a

            let pairKey = [a, b].sorted().joined(separator: "|")
            let key = "\(roundType)|\(tag)|\(pairKey)"
            if usedCombos.contains(key) { continue }

            usedCombos.insert(key)
            normalWord = normal
            impostorWord = imp
            categoryTitle = roundMode.label
            return
        }

        // Saturated fallback
        fallbackTwoRandomWords(from: typedItems.map { $0.text })
        categoryTitle = roundMode.label
    }

    // ✅ SIMPLIFIED: Use ALL non-type tags for pairing
    private func allowedPairTags(from tags: [String]) -> [String] {
        // Remove type:* tags, keep everything else (theme, era, role, league, etc.)
        return tags.filter { !$0.hasPrefix("type:") }
    }

    // ✅ NEW: Helper to detect nationality tags
    private func isNationalityTag(_ tag: String) -> Bool {
        let nationalityTags = [
            "theme:france", "theme:brazil", "theme:argentina", "theme:portugal",
            "theme:spain", "theme:germany", "theme:england", "theme:italy",
            "theme:netherlands", "theme:belgium", "theme:croatia", "theme:morocco",
            "theme:senegal", "theme:egypt", "theme:algeria", "theme:cameroon",
            "theme:ivory_coast", "theme:ghana", "theme:nigeria", "theme:poland",
            "theme:uruguay", "theme:sweden", "theme:norway", "theme:denmark",
            "theme:wales", "theme:scotland", "theme:ireland", "theme:czech_republic",
            "theme:serbia", "theme:ukraine", "theme:bulgaria", "theme:costa_rica"
        ]
        return nationalityTags.contains(tag)
    }

    private func fallbackTwoRandomWords(from words: [String]) {
        guard let w1 = words.randomElement() else {
            normalWord = "—"; impostorWord = "—"
            return
        }
        var w2 = w1
        var safety = 0
        while w2 == w1 && safety < 60 {
            w2 = words.randomElement() ?? w1
            safety += 1
        }

        if Bool.random() {
            normalWord = w1
            impostorWord = w2
        } else {
            normalWord = w2
            impostorWord = w1
        }
    }
}
