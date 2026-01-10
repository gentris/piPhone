    import SwiftUI

    struct KeyboardAccessoryView: View {
        let onTap: (KeyName) -> Void

        var body: some View {
            GeometryReader { geo in
                HStack(spacing: 5) {
                    keycap(keys[.esc]!)
                    keycap(keys[.ctrl]!)
                    keycap(keys[.tab]!)

                    Spacer(minLength: 10)

                    keycap(keys[.left]!)
                    keycap(keys[.down]!)
                    keycap(keys[.up]!)
                    keycap(keys[.right]!)
                }
                .padding(.horizontal, 4)
                .frame(width: geo.size.width - 20, height: 44) // <-- 10 padding on each side
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.thickMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.black.opacity(0.18))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.white.opacity(0.10), lineWidth: 1)
                        )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top, 6)
            }
            .frame(height: 50)
        }

        private func keycap(_ key: Key) -> some View {
            Button(action: { onTap(key.name) }) {
                Text(key.title)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.primary)
                    .frame(minWidth: 46, minHeight: 36)
            }.buttonStyle(KeycapButtonStyle())
        }
    }

    private struct KeycapButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .background(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(keyFill(isPressed: configuration.isPressed))
                )
                .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
                .animation(.easeOut(duration: 0.07), value: configuration.isPressed)
        }

        private func keyFill(isPressed: Bool) -> Color {
            let base = UIColor { trait in
                if trait.userInterfaceStyle == .dark {
                    return isPressed ? UIColor.systemGray3 : UIColor.systemGray4
                } else {
                    return isPressed ? UIColor.systemGray5 : UIColor.white
                }
            }
            return Color(uiColor: base)
        }
    }
