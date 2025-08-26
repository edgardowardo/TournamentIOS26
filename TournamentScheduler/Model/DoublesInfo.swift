
import SwiftData

@Model
final class DoublesInfo {
    var leftParticipant2: Participant? = nil
    var rightParticipant2: Participant? = nil
    
    init(leftParticipant2: Participant? = nil, rightParticipant2: Participant? = nil) {
        self.leftParticipant2 = leftParticipant2
        self.rightParticipant2 = rightParticipant2
    }
}
