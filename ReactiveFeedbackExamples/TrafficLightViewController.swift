import UIKit
import ReactiveFeedback
import ReactiveSwift
import Result

class TrafficLightViewController: UIViewController {
    @IBOutlet weak var redView: UIView!
    @IBOutlet weak var yellowView: UIView!
    @IBOutlet weak var greenView: UIView!
    private let viewModel = TrafficLightViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.state.producer.startWithValues { [weak self] (state) in
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

final class TrafficLightViewModel {
    let state: Property<State>
    
    init() {
        self.state = Property(
            initial: .red,
            reduce: TrafficLightViewModel.reduce,
            feedbacks: [
                TrafficLightViewModel.whenRed(),
                TrafficLightViewModel.whenYellow(),
                TrafficLightViewModel.whenGreen()
            ]
        )
    }
    
    private static func reduce(state: State, event: Event) -> State {
        switch state {
        case .red:
            return .yellow
        case .yellow:
            return .green
        case .green:
            return .red
        }
    }
    
    private static func whenRed() -> Feedback<State, Event> {
        return Feedback { state -> SignalProducer<Event, NoError> in
            guard case .red = state else { return .empty }
            
            return SignalProducer(value: Event.next)
                .delay(1, on: QueueScheduler.main)
        }
    }
    
    private static func whenYellow() -> Feedback<State, Event> {
        return Feedback { state -> SignalProducer<Event, NoError> in
            guard case .yellow = state else { return .empty }
            
            return SignalProducer(value: Event.next)
                .delay(2, on: QueueScheduler.main)
        }
    }
    
    private static func whenGreen() -> Feedback<State, Event> {
        return Feedback { state -> SignalProducer<Event, NoError> in
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

