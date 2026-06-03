import SwiftUI
import LiquidGlassKit

struct LiquidGlassKitView: UIViewRepresentable {
    var style: LiquidGlassEffect.Style = .regular
    var tintColor: UIColor = .white.withAlphaComponent(0.15)
    var cornerRadius: CGFloat = 24
    
    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        container.clipsToBounds = true
        container.layer.cornerRadius = cornerRadius
        container.layer.cornerCurve = .continuous
        
        let effect = LiquidGlassEffect(style: style, isNative: false)
        effect.tintColor = tintColor
        
        let effectView = LiquidGlassEffectView(effect: effect)
        effectView.frame = container.bounds
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        container.addSubview(effectView)
        
        return container
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.layer.cornerRadius = cornerRadius
    }
}


struct HybridLiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat
    var tintColor: Color
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.clear)
                        .glassEffect(
                            .regular.tint(tintColor.opacity(0.15)),
                            in: .rect(cornerRadius: cornerRadius)
                        )
                )
        } else {
            content
                .background(
                    LiquidGlassKitView(
                        style: .regular,
                        tintColor: UIColor(tintColor.opacity(0.15)),
                        cornerRadius: cornerRadius
                    )
                )
        }
    }
}


extension View {
    func hybridLiquidGlass(cornerRadius: CGFloat = 24, tint: Color = .white) -> some View {
        self.modifier(HybridLiquidGlassModifier(cornerRadius: cornerRadius, tintColor: tint))
    }
}
