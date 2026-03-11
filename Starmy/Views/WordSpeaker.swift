import AVFoundation
import Combine

@MainActor
final class WordSpeaker: NSObject, ObservableObject {

    private let synthesizer = AVSpeechSynthesizer()
    private var voicePlayers: [String: AVAudioPlayer] = [:]
    private weak var activeVoicePlayer: AVAudioPlayer?

    private static let phraseClipMap: [String: String] = [
        "welcome to starmy": "voice_welcome_to_starmy",
        "try again": "voice_try_again",
        "yes thats right": "voice_yes_thats_right",
        "keep going": "voice_keep_going",
        "halfway there": "voice_halfway_there",
        "almost done": "voice_almost_done",
        "trace a to z uppercase lowercase": "voice_trace_a_to_z_upper_lower",
        "lets draw pick up your brush": "voice_lets_draw_pick_up",
        "let s draw pick up your brush": "voice_lets_draw_pick_up",
        "lets fill in the letters you can do it": "voice_fill_a_z",
        "let s fill in the letters you can do it": "voice_fill_a_z",
        "you can do it": "voice_you_can_do_it",
    ]

    private static let fillWordClipMap: [String: String] = [
        "BAG": "fill_word_bag",
        "BAT": "fill_word_bat",
        "CAT": "fill_word_cat",
        "HEN": "fill_word_hen",
        "KEY": "fill_word_key",
        "PIG": "fill_word_pig",
        "SUN": "fill_word_sun",
        "APPLE": "fill_word_apple",
        "BOOK": "fill_word_book",
        "STAR": "fill_word_star",
        "CUP": "fill_word_cup",
        "DOG": "fill_word_dog",
    ]

    private static let lookForLetterClipMap: [Character: String] = [
        "A": "voice_look_for_a",
        "B": "voice_look_for_b",
        "E": "voice_look_for_e",
        "I": "voice_look_for_i",
        "O": "voice_look_for_o",
        "U": "voice_look_for_u",
    ]

    private static let letterClipMap: [Character: String] = {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return Dictionary(uniqueKeysWithValues: letters.map { ch in
            (ch, "voice_letter_\(String(ch).lowercased())")
        })
    }()

    private static let allKnownClips: Set<String> = {
        var clips = Set(phraseClipMap.values)
        clips.formUnion(fillWordClipMap.values)
        clips.formUnion(lookForLetterClipMap.values)
        clips.formUnion(letterClipMap.values)
        return clips
    }()

    override init() {
        super.init()
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .spokenAudio,
                                 options: [.mixWithOthers, .duckOthers])
        try? session.setActive(true)
        #endif
        preloadVoiceClips()
    }

    func speakLetter(_ letter: Character) {
        let upper = Character(String(letter).uppercased())
        if playRecordedLetterClip(for: upper) {
            return
        }
        speakWithSynth(
            String(upper).lowercased(),
            rate: 0.38,
            pitch: 1.35
        )
    }

    func speak(_ text: String) {
        if playClipForText(text) { return }
        speakWithSynth(text, rate: 0.42, pitch: 1.30)
    }

    func playWelcomeToStarmy() {
        if playClip(named: "welcome_to_starmy") { return }
        if playClip(named: "Welcome to Starmy") { return }
        if playClip(named: "voice_welcome_to_starmy") { return }
        speakWithSynth("Welcome to Starmy!", rate: 0.42, pitch: 1.30)
    }

    func playTraceAToZUppercaseLowercase() {
        if playClip(named: "trace_a_to_z_uppercase_lowercase") { return }
        if playClip(named: "Trace A to Z upperca") { return }
        if playClip(named: "voice_trace_a_to_z_upper_lower") { return }
        speakWithSynth("Trace A to Z! Uppercase and lowercase!", rate: 0.42, pitch: 1.30)
    }

    func playLetsDrawPickUpYourBrush() {
        if playClip(named: "lets_draw_pick_up_your_brush") { return }
        if playClip(named: "Let s draw pick up y") { return }
        if playClip(named: "voice_lets_draw_pick_up") { return }
        speakWithSynth("Let's draw! Pick up your brush!", rate: 0.42, pitch: 1.30)
    }

    func playTryAgain() {
        if playClip(named: "try_again") { return }
        if playClip(named: "Try again") { return }
        if playClip(named: "voice_try_again") { return }
        speakWithSynth("Try again!", rate: 0.42, pitch: 1.30)
    }

    func playKeepGoing() {
        if playClip(named: "keep_going") { return }
        if playClip(named: "keep going ") { return }
        if playClip(named: "voice_keep_going") { return }
        speakWithSynth("Keep going!", rate: 0.42, pitch: 1.30)
    }

    func playHalfwayThere() {
        if playClip(named: "halfway_there") { return }
        if playClip(named: "HALFWAY there ") { return }
        if playClip(named: "voice_halfway_there") { return }
        speakWithSynth("Halfway there!", rate: 0.42, pitch: 1.30)
    }

    func playAlmostDone() {
        if playClip(named: "almost_done") { return }
        if playClip(named: "Almost done") { return }
        if playClip(named: "voice_almost_done") { return }
        speakWithSynth("Almost done!", rate: 0.42, pitch: 1.30)
    }

    func playLookForLetter(_ letter: Character) {
        let upper = Character(String(letter).uppercased())
        switch upper {
        case "A":
            if playClip(named: "look_for_a") { return }
            if playClip(named: "Look for the A") { return }
            if playClip(named: "voice_look_for_a") { return }
        case "B":
            if playClip(named: "look_for_b") { return }
            if playClip(named: "Look for the B") { return }
            if playClip(named: "voice_look_for_b") { return }
        case "E":
            if playClip(named: "look_for_e") { return }
            if playClip(named: "Look for the E") { return }
            if playClip(named: "voice_look_for_e") { return }
        case "I":
            if playClip(named: "look_for_i") { return }
            if playClip(named: "Look for the I") { return }
            if playClip(named: "voice_look_for_i") { return }
        case "O":
            if playClip(named: "look_for_o") { return }
            if playClip(named: "Look for the O") { return }
            if playClip(named: "voice_look_for_o") { return }
        case "U":
            if playClip(named: "look_for_u") { return }
            if playClip(named: "Look for the U") { return }
            if playClip(named: "voice_look_for_u") { return }
        default:
            break
        }
        speakWithSynth("Look for the \(String(upper))!", rate: 0.42, pitch: 1.30)
    }

    func spellThenSpeak(_ word: String) {
        let upperWord = word.uppercased()
        if let clip = Self.fillWordClipMap[upperWord], playClip(named: clip) {
            return
        }

        let spelled = word.lowercased().map { String($0) }.joined(separator: "... ")
        let fullText = "\(spelled)... \(word.lowercased())"
        speakWithSynth(fullText, rate: 0.35, pitch: 1.30)
    }

    @discardableResult
    func playFillWordCelebration(_ word: String) -> TimeInterval {
        let upperWord = word.uppercased()
        let candidates: [String]
        switch upperWord {
        case "BAG":
            candidates = [
                "voice_yes_thats_right_its_2",
                "yes that s right its",
                "fill_word_bag",
                "voice_yes_thats_right_its_2",
                "Yes That s right it -2",
            ]
        case "BAT":
            candidates = ["fill_word_bat", "voice_yes_thats_right_its_3", "Yes That s right it -3"]
        case "CAT":
            candidates = ["fill_word_cat", "voice_yes_thats_right_its_4", "Yes That s right it -4"]
        case "HEN":
            candidates = ["fill_word_hen", "voice_yes_thats_right_its_5", "Yes That s right it -5"]
        case "KEY":
            candidates = ["fill_word_key", "voice_yes_thats_right_its_6", "Yes That s right it -6"]
        case "PIG":
            candidates = ["fill_word_pig", "voice_yes_thats_right_its"]
        case "SUN":
            candidates = ["fill_word_sun", "voice_yes_thats_right_its_7", "Yes That s right it -7"]
        default:
            candidates = []
        }

        for clip in candidates {
            if let duration = playClipAndGetDuration(named: clip) {
                return duration
            }
        }

        let genericCandidates = [
            "voice_yes_thats_right_its",
            "yes that s right its",
            "voice_yes_thats_right_you",
            "Yes That s right You",
            "voice_yes_thats_right",
            "Yes That s right",
        ]
        for clip in genericCandidates {
            if let duration = playClipAndGetDuration(named: clip) {
                return duration
            }
        }

        stopCurrentOutput()
        return 1.8
    }

    private func playClipForText(_ text: String) -> Bool {
        let normalized = Self.normalize(text)
        if let clipName = Self.phraseClipMap[normalized], playClip(named: clipName) {
            return true
        }

        if normalized.contains("keep going"), playClip(named: "keep_going") {
            return true
        }
        if normalized.contains("keep going"), playClip(named: "voice_keep_going") {
            return true
        }
        if normalized.contains("you can do it"), playClip(named: "voice_you_can_do_it") {
            return true
        }

        if let lookLetter = Self.lookForLetter(in: normalized),
           let clipName = Self.lookForLetterClipMap[lookLetter],
           playClip(named: clipName) {
            return true
        }

        return false
    }

    private func playRecordedLetterClip(for upper: Character) -> Bool {
        let letter = String(upper)
        let lower = letter.lowercased()

        let baseCandidates: [String?] = [
            Self.letterClipMap[upper],
            "voice_letter_\(lower)",
            letter,
            lower,
            " \(letter) ",
            " \(letter)",
            "\(letter) ",
        ]
        let candidates = baseCandidates.compactMap { $0 }

        for clipName in candidates {
            if playClip(named: clipName) {
                return true
            }
        }

        if let discovered = discoverSingleLetterClipName(for: upper),
           playClip(named: discovered) {
            return true
        }

        return false
    }

    private func playClip(named clipName: String) -> Bool {
        stopCurrentOutput()
        guard let player = playerForClip(named: clipName) else { return false }
        player.currentTime = 0
        guard player.play() else { return false }
        activeVoicePlayer = player
        return true
    }

    private func playClipAndGetDuration(named clipName: String) -> TimeInterval? {
        stopCurrentOutput()
        guard let player = playerForClip(named: clipName) else { return nil }
        player.currentTime = 0
        guard player.play() else { return nil }
        activeVoicePlayer = player
        return player.duration
    }

    private func speakWithSynth(_ text: String, rate: Float, pitch: Float) {
        stopCurrentOutput()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = rate
        utterance.pitchMultiplier = pitch
        utterance.volume = 1.0
        synthesizer.speak(utterance)
    }

    private func stopCurrentOutput() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        if let player = activeVoicePlayer, player.isPlaying {
            player.stop()
            player.currentTime = 0
        }
    }

    private func preloadVoiceClips() {
        for clip in Self.allKnownClips {
            _ = playerForClip(named: clip)
        }
    }

    private func playerForClip(named clipName: String) -> AVAudioPlayer? {
        if let player = voicePlayers[clipName] {
            return player
        }
        guard let url = clipURL(named: clipName) else {
            return nil
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            voicePlayers[clipName] = player
            return player
        } catch {
            print("[WordSpeaker] failed to load \(clipName): \(error)")
            return nil
        }
    }

    private func clipURL(named clipName: String) -> URL? {
        if let url = Bundle.main.url(forResource: clipName, withExtension: "mp3", subdirectory: "Sounds/Voice") {
            return url
        }
        if let url = Bundle.main.url(forResource: clipName, withExtension: "mp3") {
            return url
        }
        return Bundle.main.urls(forResourcesWithExtension: "mp3", subdirectory: nil)?
            .first(where: { $0.deletingPathExtension().lastPathComponent == clipName })
    }

    private func discoverSingleLetterClipName(for upper: Character) -> String? {
        let target = String(upper).lowercased()
        let urls = Bundle.main.urls(forResourcesWithExtension: "mp3", subdirectory: nil) ?? []
        for url in urls {
            let baseName = url.deletingPathExtension().lastPathComponent
            let alphaOnly = baseName.lowercased().replacingOccurrences(
                of: "[^a-z]",
                with: "",
                options: .regularExpression
            )
            if alphaOnly == target {
                return baseName
            }
        }
        return nil
    }

    private static func normalize(_ text: String) -> String {
        text
            .lowercased()
            .replacingOccurrences(
                of: "[^a-z0-9]+",
                with: " ",
                options: .regularExpression
            )
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func lookForLetter(in normalizedText: String) -> Character? {
        let prefix = "look for the "
        guard normalizedText.hasPrefix(prefix) else { return nil }
        let suffix = normalizedText.dropFirst(prefix.count)
        guard let first = suffix.first else { return nil }
        let upper = Character(String(first).uppercased())
        return lookForLetterClipMap.keys.contains(upper) ? upper : nil
    }
}
