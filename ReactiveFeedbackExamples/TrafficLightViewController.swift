import UIKit
import Loop
import ReactiveSwift

class TrafficLightViewController: UIViewController {
    @IBOutlet weak var redView: UIView!
    @IBOutlet weak var yellowView: UIView!
    @IBOutlet weak var greenView: UIView!
    private let viewModel = TrafficLightViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.state.startWithValues { [weak self] (state) in
            self?.render(state: state)
        }
    }
    
    func render(state: TrafficLightViewModel.State) {
        UIView.animate(withDuration: 0.3) {
            switch state {
            case .red:
                self.redView.alpha = 1
                self.yellowView.alpha = 0.5
                self.greenView.alpha = 0.5
            case .yellow:
                self.redView.alpha = 0.5
                self.yellowView.alpha = 1
                self.greenView.alpha = 0.5
            case .green:
                self.redView.alpha = 0.5
                self.yellowView.alpha = 0.5
                self.greenView.alpha = 1
            }
        }
    }
}

final class TrafficLightViewModel: BaseLoopViewModel<TrafficLightViewModel.State, TrafficLightViewModel.Event> {
    init() {
        super.init(
            initial: .red,
            reduce: TrafficLightViewModel.reduce,
            feedbacks: [
                TrafficLightViewModel.whenRed(),
                TrafficLightViewModel.whenYellow(),
                TrafficLightViewModel.whenGreen()
            ]
        )
    }
    
    private static func reduce(state: inout State, event: Event) {
        switch state {
        case .red:
            state = .yellow
        case .yellow:
            state = .green
        case .green:
            state = .red
        }
    }
    
    private static func whenRed() -> FeedbackLoop<State, Event>.Feedback {
        return .init { state -> SignalProducer<Event, Never> in
            guard case .red = state else { return .empty }
            
            return SignalProducer(value: Event.next)
                .delay(1, on: QueueScheduler.main)
        }
    }
    
    private static func whenYellow() -> FeedbackLoop<State, Event>.Feedback {
        return .init { state -> SignalProducer<Event, Never> in
            guard case .yellow = state else { return .empty }
            
            return SignalProducer(value: Event.next)
                .delay(2, on: QueueScheduler.main)
        }
    }
    
    private static func whenGreen() -> FeedbackLoop<State, Event>.Feedback {
        return .init { state -> SignalProducer<Event, Never> in
            guard case .green = state else { return .empty }
            
            return SignalProducer(value: Event.next)
                .delay(3, on: QueueScheduler.main)
        }
    }
    
    enum State {
        case red
        case yellow
        case green
    }
    
    enum Event {
        case next
    }
}

