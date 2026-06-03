//
//  LiquidGlass.swift
//  SpotifyClone
//
//  Reusable liquid-glass surfaces. On iOS 26+ these use the native
//  `glassEffect` API; on earlier systems they gracefully fall back to a
//  hand-tuned material + gradient stroke that reads as frosted glass.
//

import SwiftUI

/// A frosted "liquid glass" container with a subtle highlight stroke.
struct LiquidGlassBackground: View {
    var cornerRadius: CGFloat = 24
    var tint: Color = .white

    var body: some View {
        if #available(iOS 26.0, *) {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.clear)
                .glassEffect(.regular.tint(tint.opacity(0.06)), in: .rect(cornerRadius: cornerRadius))
                .overlay(highlightStroke)
        } else {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [tint.opacity(0.10), .clear, .black.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .overlay(highlightStroke)
        }
    }

    private var highlightStroke: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .strokeBorder(
                LinearGradient(
                    colors: [.white.opacity(0.35), .white.opacity(0.05), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
    }
}

/// Applies a liquid-glass surface behind any view.
struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var tint: Color = .white

    func body(content: Content) -> some View {
        content.background(LiquidGlassBackground(cornerRadius: cornerRadius, tint: tint))
    }
}

extension View {
    /// Wrap the view in a liquid-glass surface.
    func glassCard(cornerRadius: CGFloat = 20, tint: Color = .white) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius, tint: tint))
    }
}

/// A circular glass button used for player controls and pills.
struct GlassIconButton: View {
    let systemName: String
    var size: CGFloat = 44
    var iconSize: CGFloat = 18
    var tint: Color = .white
    let action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        } label: {
            Image(systemName: systemName)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: size, height: size)
                .background(LiquidGlassBackground(cornerRadius: size / 2, tint: tint))
                .scaleEffect(pressed ? 0.88 : 1)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) { pressed = true } }
                .onEnded { _ in withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { pressed = false } }
        )
    }
}
