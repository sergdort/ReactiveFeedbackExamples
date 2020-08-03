import Loop
import ReactiveSwift

final class RAFLoginViewModel: BaseLoopViewModel<RAFLoginViewModel.State, RAFLoginViewModel.Event> {
    init() {
        super.init(
            initial: State(),
            reduce: Self.reduce(state:event:),
            feedbacks: [
                Self.whenLoading(loginService: LogInService()),
            ]
        )
    }
    
    func didChangePassword(_ password: String) {
        send(event: .didChangePassword(password))
    }
    
    func didChangeUsername(_ username: String) {
        send(event: .didChangeUsername(username))
    }
    
    func didTapSignIn() {
        send(event: .startLoading)
    }
    
    private static func whenLoading(loginService: LogInService) -> FeedbackLoop<State, Event>.Feedback {
        return .init(
            predicate: { $0.isLoading },
            effects: { (state: State) -> SignalProducer<Event, Never> in
                return loginService.rac_login(username: state.username, password: state.password)
                    .map(Event.didAuth)
            }
        )
    }
    
    private static func reduce(state: inout State, event: Event) {
        switch event {
        case .didAuth(let isAuthorized):
            state.isAuthorized = isAuthorized
            state.isLoading = false
            state.status = isAuthorized ? "Success" : "Unauthorized"
        case .didChangeUsername(let username):
            state.username = username
        case .didChangePassword(let password):
            state.password = password
        case .startLoading:
            state.isLoading = true
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

