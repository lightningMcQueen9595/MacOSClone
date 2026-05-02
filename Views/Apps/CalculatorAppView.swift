import SwiftUI

// MARK: - Calculator App
struct CalculatorAppView: View {
    @State private var display: String = "0"
    @State private var firstOperand: Double? = nil
    @State private var currentOp: CalcOp? = nil
    @State private var shouldResetDisplay = false

    enum CalcOp { case add, sub, mul, div }

    private let buttons: [[CalcButton]] = [
        [.clear, .sign, .percent, .op(.div)],
        [.digit("7"), .digit("8"), .digit("9"), .op(.mul)],
        [.digit("4"), .digit("5"), .digit("6"), .op(.sub)],
        [.digit("1"), .digit("2"), .digit("3"), .op(.add)],
        [.digit("0"), .decimal, .equals]
    ]

    enum CalcButton: Hashable {
        case digit(String), op(CalcOp), equals, clear, sign, percent, decimal

        var isTopRow: Bool {
            switch self {
            case .clear, .sign, .percent: return true
            default: return false
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Display
            HStack {
                Spacer()
                Text(display)
                    .font(.system(size: min(56, 56 * (8.0 / max(8.0, Double(display.count)))),
                                  weight: .thin, design: .default))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(Color.black)

            // Buttons
            VStack(spacing: 1) {
                ForEach(buttons.indices, id: \.self) { row in
                    HStack(spacing: 1) {
                        ForEach(buttons[row], id: \.self) { btn in
                            CalcButtonView(button: btn) {
                                handleButton(btn)
                            }
                        }
                    }
                }
            }
            .background(Color(white: 0.15))
        }
        .background(Color.black)
    }

    // MARK: - Logic
    private func handleButton(_ btn: CalcButton) {
        HapticManager.shared.impact(.light)
        switch btn {
        case .digit(let d):
            if shouldResetDisplay || display == "0" {
                display = d
                shouldResetDisplay = false
            } else {
                if display.count < 9 { display += d }
            }
        case .decimal:
            if !display.contains(".") { display += "." }
        case .clear:
            display = "0"; firstOperand = nil; currentOp = nil
        case .sign:
            if let v = Double(display) { display = formatResult(-v) }
        case .percent:
            if let v = Double(display) { display = formatResult(v / 100) }
        case .op(let op):
            firstOperand = Double(display)
            currentOp = op
            shouldResetDisplay = true
        case .equals:
            guard let first = firstOperand, let op = currentOp,
                  let second = Double(display) else { return }
            var result: Double
            switch op {
            case .add: result = first + second
            case .sub: result = first - second
            case .mul: result = first * second
            case .div: result = second != 0 ? first / second : 0
            }
            display = formatResult(result)
            firstOperand = nil; currentOp = nil
            shouldResetDisplay = true
        }
    }

    private func formatResult(_ v: Double) -> String {
        if v.truncatingRemainder(dividingBy: 1) == 0 && abs(v) < 1_000_000_000 {
            return String(Int(v))
        }
        return String(format: "%.6g", v)
    }
}

// MARK: - Calc Button View
struct CalcButtonView: View {
    let button: CalculatorAppView.CalcButton
    let action: () -> Void
    @State private var isPressed = false

    var label: String {
        switch button {
        case .digit(let d): return d
        case .op(let o):
            switch o {
            case .add: return "+"
            case .sub: return "−"
            case .mul: return "×"
            case .div: return "÷"
            }
        case .equals:   return "="
        case .clear:    return "AC"
        case .sign:     return "+/−"
        case .percent:  return "%"
        case .decimal:  return "."
        }
    }

    var bgColor: Color {
        switch button {
        case .op, .equals: return Color(red: 1.0, green: 0.62, blue: 0.04)
        case .clear, .sign, .percent: return Color(white: 0.65)
        default: return Color(white: 0.28)
        }
    }

    var isWide: Bool {
        if case .digit("0") = button { return true }
        return false
    }

    var body: some View {
        Text(label)
            .font(.system(size: 28, weight: .regular))
            .foregroundStyle(button.isTopRow ? .black : .white)
            .frame(maxWidth: isWide ? .infinity : nil)
            .frame(width: isWide ? nil : 64, height: 64)
            .background(isPressed ? bgColor.opacity(0.6) : bgColor)
            .clipShape(Capsule())
            .contentShape(Capsule())
            .frame(maxWidth: .infinity)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed { isPressed = true }
                    }
                    .onEnded { _ in
                        isPressed = false
                        action()
                    }
            )
    }
}
