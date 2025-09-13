
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
            SingleEliminationScheduler(pool: pool).schedule()
        case .doubleElimination:
            DoubleEliminationScheduler(pool: pool).schedule()
        }
    }
}

protocol ScheduleProviding {
    var pool: Pool { get }
    func schedule()
}
