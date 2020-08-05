import Loop
import ReactiveSwift

final class RAFLoginViewModel: BaseLoopViewModel<RAFLoginViewModel.State, RAFLoginViewModel.Event> {
    init(loginService: LogInService = LogInService()) {
        super.init(
            initial: State(),
            reduce: Self.reduce(state:event:),
            feedbacks: [
                Self.whenLoading(loginService: loginService),
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
        return .init { (state) -> SignalProducer<Event, Never> in
            guard state.isLoading else {
                return .empty
            }
            return loginService.rac_login(
                username: state.username,
                password: state.password
            )
            .map(Event.didAuth)
        }
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
    
    struct State {
        var isLoading = false
        fileprivate var isAuthorized = false
        fileprivate var username = ""
        fileprivate var password = ""
        var status = ""
        
        var canLogin: Bool {
            return !isLoading && !username.isEmpty && !password.isEmpty
        }
    }
    
    enum Event {
        case didAuth(Bool)
        case didChangeUsername(String)
        case didChangePassword(String)
        case startLoading
    }

}

