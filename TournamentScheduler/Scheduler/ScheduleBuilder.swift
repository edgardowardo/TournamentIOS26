
// Given a Pool, and it's schedule type, schedule rounds of matches
struct ScheduleBuilder {
    
    var pool: Pool
    
    func schedule() {
        switch pool.schedule {
        case .roundRobin:
            RoundRobinScheduler(pool: pool).schedule()
        case .americanDoubles:
            AmericanDoublesScheduler(pool: pool).schedule()
        case .singleElimination:
            return
        case .doubleElimination:
            return
        }
    }
}


protocol ScheduleProviding {
    var pool: Pool { get }
    func schedule()
}
