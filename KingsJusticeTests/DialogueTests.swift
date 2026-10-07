import XCTest
@testable import KingsJustice

final class DialogueTests: XCTestCase {
    
    let enemyIds = [
        "hollow_conscript",
        "pyre_marauder",
        "frost_warden",
        "marsh_hag_knight",
        "crimson_executioner",
        "bishop_of_ash",
        "the_king"
    ]
    
    let enemyEvents: [Dialogue.Event] = [
        .intro,
        .phase,
        .onPlayerPerfect,
        .onPlayerHit,
        .onEnemyHitsPlayer,
        .onLowHealth,
        .onVictory,
        .onDefeat
    ]
    
    /// Test that every enemy ID has non-empty pools for all enemy events.
    func testEveryEnemyIdHasNonEmptyPoolsForEveryEvent() {
        for enemyId in enemyIds {
            for event in enemyEvents {
                let lines = Dialogue.lines(for: event, enemyId: enemyId)
                XCTAssertFalse(
                    lines.isEmpty,
                    "Expected non-empty dialogue pool for enemy '\(enemyId)' on event '\(event)'"
                )
                
                let lineFromSeed = Dialogue.line(event, enemyId: enemyId, seed: 0)
                XCTAssertNotNil(
                    lineFromSeed,
                    "Expected non-nil line for enemy '\(enemyId)' on event '\(event)' with seed 0"
                )
            }
        }
    }
    
    /// Test that all dialogue lines are <= 90 characters and contain no em dash characters.
    func testLineLengthsAndNoEmDash() {
        for enemyId in enemyIds {
            for event in enemyEvents {
                let lines = Dialogue.lines(for: event, enemyId: enemyId)
                for line in lines {
                    XCTAssertLessThanOrEqual(
                        line.count,
                        90,
                        "Line length for '\(enemyId)'/\(event) exceeds 90 characters: '\(line)' (\(line.count) chars)"
                    )
                    XCTAssertFalse(
                        line.contains("—"),
                        "Line for '\(enemyId)'/\(event) contains an em dash: '\(line)'"
                    )
                    XCTAssertFalse(
                        line.contains("\u{2014}"),
                        "Line for '\(enemyId)'/\(event) contains unicode em dash: '\(line)'"
                    )
                }
            }
            
            // Check kingdom blurbs and post-victory narrations for no em dash
            let blurb = Dialogue.kingdomBlurb(for: enemyId)
            XCTAssertFalse(blurb.isEmpty, "Kingdom blurb should not be empty for '\(enemyId)'")
            XCTAssertFalse(blurb.contains("—"), "Kingdom blurb contains em dash for '\(enemyId)'")
            
            let narration = Dialogue.postVictoryNarration(for: enemyId)
            XCTAssertFalse(narration.isEmpty, "Post-victory narration should not be empty for '\(enemyId)'")
            XCTAssertFalse(narration.contains("—"), "Post-victory narration contains em dash for '\(enemyId)'")
        }
        
        // Check player lines
        for event in [Dialogue.Event.playerVictory, Dialogue.Event.playerDefeat] {
            let lines = Dialogue.lines(for: event, enemyId: "")
            XCTAssertFalse(lines.isEmpty, "Player lines should not be empty for '\(event)'")
            for line in lines {
                XCTAssertLessThanOrEqual(line.count, 90, "Player line exceeds 90 chars: '\(line)'")
                XCTAssertFalse(line.contains("—"), "Player line contains em dash: '\(line)'")
            }
        }
    }
    
    /// Test that seed-based selection is completely deterministic.
    func testDeterminismForSameSeed() {
        for enemyId in enemyIds {
            for event in enemyEvents {
                let seed = 42
                let firstCall = Dialogue.line(event, enemyId: enemyId, seed: seed)
                let secondCall = Dialogue.line(event, enemyId: enemyId, seed: seed)
                XCTAssertEqual(
                    firstCall,
                    secondCall,
                    "Expected identical line for seed \(seed) on enemy '\(enemyId)', event '\(event)'"
                )
            }
        }
    }
    
    /// Test that lineNotRepeating avoids repeating lastLine when pool size > 1.
    func testNoRepeatHelperBehaviors() {
        for enemyId in enemyIds {
            for event in enemyEvents {
                let pool = Dialogue.lines(for: event, enemyId: enemyId)
                guard pool.count > 1 else { continue }
                
                let line0 = Dialogue.line(event, enemyId: enemyId, seed: 0)!
                let nextLine = Dialogue.lineNotRepeating(event, enemyId: enemyId, seed: 0, lastLine: line0)
                
                XCTAssertNotEqual(
                    line0,
                    nextLine,
                    "Expected lineNotRepeating to avoid '\(line0)' when pool count > 1 for enemy '\(enemyId)', event '\(event)'"
                )
            }
        }
        
        // Single-item or fallback test
        let singleLine = "Only line"
        let fallback = Dialogue.lineNotRepeating(.intro, enemyId: "unknown_enemy", seed: 0, lastLine: "anything")
        XCTAssertNil(fallback, "Unknown enemy should return nil")
    }
    
    /// Test kingdom blurb and post-victory narration lookup.
    func testKingdomBlurbAndNarration() {
        for enemyId in enemyIds {
            let blurb = Dialogue.kingdomBlurb(for: enemyId)
            XCTAssertNotEqual(blurb, "A shadowy arena lies ahead...", "Enemy '\(enemyId)' should have a custom kingdom blurb")
            
            let narration = Dialogue.postVictoryNarration(for: enemyId)
            XCTAssertNotEqual(narration, "Victory brings the realm one step closer to justice.", "Enemy '\(enemyId)' should have a custom post-victory narration")
        }
    }
    
    /// Test player line lookup.
    func testPlayerLines() {
        let victoryLine0 = Dialogue.playerLine(for: .playerVictory, seed: 0)
        let victoryLine1 = Dialogue.playerLine(for: .playerVictory, seed: 1)
        XCTAssertNotNil(victoryLine0)
        XCTAssertNotNil(victoryLine1)
        
        let defeatLine0 = Dialogue.playerLine(for: .playerDefeat, seed: 0)
        XCTAssertNotNil(defeatLine0)
        
        // Non-player event for playerLine should return nil
        let invalid = Dialogue.playerLine(for: .intro, seed: 0)
        XCTAssertNil(invalid)
    }
}
