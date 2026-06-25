import SwiftUI
import UIKit

// MARK: - Offline Banner
struct OfflineBanner: View {
    var message: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(HAA.Colors.orange)
            Text(message)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(HAA.Colors.charcoal)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HAA.Colors.orangeLight)
        .overlay(
            Rectangle()
                .fill(HAA.Colors.orange.opacity(0.2))
                .frame(height: 0.5),
            alignment: .bottom
        )
    }
}

// MARK: - Top Navigation Bar
struct HAANavBar: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        HStack(spacing: 12) {
            Image("AppLogo")
                .resizable()
                .scaledToFill()
                .frame(width: 34, height: 34)
                .clipShape(RoundedRectangle(cornerRadius: 9))
                .overlay(
                    RoundedRectangle(cornerRadius: 9)
                        .stroke(HAA.Colors.gold.opacity(0.25), lineWidth: 0.5)
                )

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(HAA.Font.serif(16, weight: .semibold))
                    .foregroundColor(Color(hex: "#F5E8C0"))
                if let sub = subtitle {
                    Text(sub)
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundColor(HAA.Colors.mutedLight)
                }
            }

            Spacer()
        }
        .padding(.horizontal, HAA.Spacing.lg)
        .padding(.vertical, 12)
        .background(HAA.Colors.charcoal)
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    var action: String? = nil
    var onAction: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .tracking(1.0)
                .foregroundColor(HAA.Colors.muted)

            Spacer()

            if let action = action {
                Button(action: { onAction?() }) {
                    Text(action)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(HAA.Colors.orange)
                }
            }
        }
        .padding(.horizontal, HAA.Spacing.lg)
        .padding(.top, 20)
        .padding(.bottom, 8)
    }
}

// MARK: - Tag Chip
struct EventTagChip: View {
    let tag: EventTag

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: tag.systemIcon)
                .font(.system(size: 9, weight: .semibold))
            Text(tag.rawValue)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .tracking(0.3)
        }
        .foregroundColor(tag.foregroundColor)
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(tag.backgroundColor)
        .clipShape(Capsule())
    }
}

// MARK: - Highlight Pill
struct HighlightBadge: View {
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "star.fill")
                .font(.system(size: 8))
            Text("Highlight")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .tracking(0.3)
        }
        .foregroundColor(HAA.Colors.gold)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(HAA.Colors.gold.opacity(0.12))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(HAA.Colors.gold.opacity(0.3), lineWidth: 0.5))
    }
}

// MARK: - Location Category Pill
struct CategoryPill: View {
    let label: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                Text(label)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
            }
            .foregroundColor(isSelected ? HAA.Colors.gold : HAA.Colors.muted)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(isSelected ? HAA.Colors.charcoal : Color.white)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(
                    isSelected ? Color.clear : HAA.Colors.border,
                    lineWidth: 0.5
                )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Orange CTA Button
struct HAAButton: View {
    let label: String
    let icon: String?
    let action: () -> Void
    var style: ButtonStyle = .filled

    enum ButtonStyle { case filled, outline }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                }
                Text(label)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            .foregroundColor(style == .filled ? .white : HAA.Colors.orange)
            .padding(.horizontal, 20)
            .padding(.vertical, 11)
            .frame(maxWidth: .infinity)
            .background(style == .filled ? HAA.Colors.orange : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: HAA.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: HAA.Radius.md)
                    .stroke(HAA.Colors.orange, lineWidth: style == .outline ? 1 : 0)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Text Field with Keyboard Done Bar
/// UIKit text field with an input accessory toolbar. Required for `.numberPad`, which has no Return key
/// and does not reliably show SwiftUI's `.toolbar(placement: .keyboard)`.
struct AccessoryTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var keyboardType: UIKeyboardType
    var textContentType: UITextContentType?
    var digitsOnly: Bool = false
    var maxLength: Int?
    var onFocusChange: (Bool) -> Void = { _ in }
    var onDone: () -> Void = {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UITextField {
        let field = UITextField()
        field.delegate = context.coordinator
        field.placeholder = placeholder
        field.keyboardType = keyboardType
        field.font = .systemFont(ofSize: 15)
        field.textColor = UIColor(Color(hex: "#1A1612"))
        field.tintColor = UIColor(Color(hex: "#C8530A"))
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.textContentType = textContentType
        field.inputAccessoryView = context.coordinator.makeToolbar()
        field.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return field
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        context.coordinator.parent = self
        if uiView.text != text {
            uiView.text = text
        }
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: AccessoryTextField

        init(parent: AccessoryTextField) {
            self.parent = parent
        }

        func makeToolbar() -> UIToolbar {
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let done = UIBarButtonItem(
                image: UIImage(systemName: "checkmark.circle.fill"),
                style: .done,
                target: self,
                action: #selector(doneTapped)
            )
            done.tintColor = UIColor(Color(hex: "#C8530A"))
            toolbar.items = [flex, done]
            return toolbar
        }

        @objc func doneTapped() {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil, from: nil, for: nil
            )
            parent.onDone()
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.onFocusChange(true)
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.onFocusChange(false)
        }

        func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {
            let current = textField.text ?? ""
            guard let textRange = Range(range, in: current) else { return false }
            var updated = current.replacingCharacters(in: textRange, with: string)
            if parent.digitsOnly {
                updated = String(updated.filter(\.isNumber))
            }
            if let max = parent.maxLength {
                updated = String(updated.prefix(max))
            }
            let natural = current.replacingCharacters(in: textRange, with: string)
            if updated != natural {
                textField.text = updated
                parent.text = updated
                return false
            }
            parent.text = updated
            return true
        }
    }
}

// MARK: - Multiline Text with Keyboard Done Bar
struct AccessoryTextView: UIViewRepresentable {
    @Binding var text: String
    var onDone: () -> Void = {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.delegate = context.coordinator
        view.font = .systemFont(ofSize: 14)
        view.text = text
        view.textColor = UIColor(Color(hex: "#1A1612"))
        view.tintColor = UIColor(Color(hex: "#C8530A"))
        view.backgroundColor = .clear
        view.autocorrectionType = .yes
        view.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        view.inputAccessoryView = context.coordinator.makeToolbar()
        return view
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        context.coordinator.parent = self
        if uiView.text != text {
            uiView.text = text
        }
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: AccessoryTextView

        init(parent: AccessoryTextView) {
            self.parent = parent
        }

        func makeToolbar() -> UIToolbar {
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let done = UIBarButtonItem(
                image: UIImage(systemName: "checkmark.circle.fill"),
                style: .done,
                target: self,
                action: #selector(doneTapped)
            )
            done.tintColor = UIColor(Color(hex: "#C8530A"))
            toolbar.items = [flex, done]
            return toolbar
        }

        @objc func doneTapped() {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil, from: nil, for: nil
            )
            parent.onDone()
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}
