//: A UIKit based Playground for presenting user interface
import UIKit
import PlaygroundSupport

class MyViewController: UIViewController {
    let recordButton = RecordButton(width: 100)

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .gray

        let label = UILabel()
        label.text = "Hola asd fasdfa dfadf "
        label.textColor = .black

        let stackView = UIStackView(arrangedSubviews: [label, recordButton])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.frame = CGRect(origin: view.center, size: CGSize(width: 200, height: 300))

        view.addSubview(stackView)

        recordButton.tapAction = {
            print("tapped")
            self.recordButton.isSelected = true
        }
        self.view = view
    }

    @objc func recordButtonTapped() {
        print("toggle")
        recordButton.isSelected = true
    }
}

final class RecordButton: UIView {

    private var redAreaLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = #colorLiteral(red: 1, green: 0.1294117647, blue: 0.1294117647, alpha: 1)
        return layer
    }()

    private var whiteAreaLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        return layer
    }()

    var tapAction: (() -> Void)?

    var isSelected: Bool = false {
        didSet {
            animate()
        }
    }

    var borderWidth: CGFloat {
        didSet {
            updateView()
        }
    }

    init(width: CGFloat, borderWidth: CGFloat = 6) {
        self.borderWidth = borderWidth
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: width, height: width)))
        updateView()
        isUserInteractionEnabled = false

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tapGesture)
    }

    required init?(coder: NSCoder) {
        self.borderWidth = 0
        super.init(coder: coder)
    }

    @objc func tapped() {
        tapAction?()
    }
}

private extension RecordButton {
    var reducedSize: CGFloat { return frame.width / 2 }
    var initialSize: CGFloat { return frame.width - borderWidth }

    func updateView() {
        let width = self.frame.width
        self.layer.backgroundColor = UIColor.white.cgColor
        let size = frame.size.width - borderWidth
        redAreaLayer.frame = CGRect(origin: CGPoint(x: frame.origin.x + borderWidth/2, y: frame.origin.y + borderWidth/2), size: CGSize(width: size, height: size))
        redAreaLayer.cornerRadius = (width - borderWidth) / 2
        whiteAreaLayer.frame = frame
        whiteAreaLayer.cornerRadius = width / 2
        self.layer.addSublayer(whiteAreaLayer)
        self.layer.addSublayer(redAreaLayer)
    }

    func animate() {
        print("Animated")

        let anim = CABasicAnimation(keyPath: "transform.scale")
        anim.fromValue = isSelected ? 1 : 0.5
        anim.toValue = isSelected ? 0.5 : 1
        anim.duration = 0.2
        anim.isRemovedOnCompletion = false
        anim.fillMode = .forwards

        redAreaLayer.add(anim, forKey: nil)
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
