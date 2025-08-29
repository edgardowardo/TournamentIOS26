
// Given a Pool, and it's schedule type, schedule rounds of matches
struct ScheduleBuilder {
    
    var pool: Pool
    
    func schedule() {
        switch pool.schedule {
        case .roundRobin:
            RoundRobinScheduler(pool: pool).schedule()
        case .american:
            return
        case .singleElimination:
            return
        case .doubleElimination:
            return
        }
    }
}
