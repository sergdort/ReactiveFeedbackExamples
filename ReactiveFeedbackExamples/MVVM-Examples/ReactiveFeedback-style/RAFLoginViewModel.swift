import ReactiveFeedback
import ReactiveSwift
import Result

final class RAFLoginViewModel {
    let state: Property<State>
    private let input = Feedback<State, Event>.input()
    
    init() {
        self.state = Property(
            initial: State(),
            reduce: RAFLoginViewModel.reduce,
            feedbacks: [
                RAFLoginViewModel.whenLoading(loginService: LogInService()),
                input.feedback
            ]
        )
    }
    
    func didChangePassword(_ password: String) {
        input.observer(.didChangePassword(password))
    }
    
    func didChangeUsername(_ username: String) {
        input.observer(.didChangeUsername(username))
    }
    
    func didTapSignIn() {
        input.observer(.startLoading)
    }
    
    private static func whenLoading(loginService: LogInService) -> Feedback<State, Event> {
        return Feedback(
            predicate: { $0.isLoading },
            effects: { (state: State) -> SignalProducer<Event, NoError> in
                return loginService.rac_login(username: state.username, password: state.password)
                    .map(Event.didAuth)
            }
        )
    }
    
    private static func reduce(state: State, event: Event) -> State {
        switch event {
        case .didAuth(let isAuthorized):
            return state.set(\.isAuthorized, isAuthorized)
                .set(\.isLoading, false)
                .set(\.status, isAuthorized ? "Success" : "Unauthorized")
        case .didChangeUsername(let username):
            return state.set(\.username, username)
        case .didChangePassword(let password):
            return state.set(\.password, password)
        case .startLoading:
            return state.set(\.isLoading, true)
                .set(\.status, "Loading...")
        }
    }
    
    struct State: With {
        var isLoading = false
        fileprivate var isAuthorized = false
        fileprivate var username = ""
        fileprivate var password = ""
        var status = ""
        
        var canLogin: Bool {
            return !isLoading && !username.isEmpty && !password.isEmpty
        }
    }
    
    private enum Event {
        case didAuth(Bool)
        case didChangeUsername(String)
        case didChangePassword(String)
        case startLoading
    }
}

public protocol With {}

extension With where Self: Any {
    
    func set<Value>(_ keyPath: WritableKeyPath<Self, Value>, _ value: Value) -> Self {
        var copy = self
        copy[keyPath: keyPath] = value
        return copy
    }
}


public extension Feedback {
    public static func input() -> (feedback: Feedback<State, Event>, observer: (Event) -> Void) {
        let pipe = Signal<Event, NoError>.pipe()
        let feedback = Feedback { (scheduler, _) -> Signal<Event, NoError> in
            return pipe.output.observe(on: scheduler)
        }
        return (feedback, pipe.input.send)
    }
}
