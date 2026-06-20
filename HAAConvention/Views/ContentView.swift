import SwiftUI

struct ContentView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var selectedTab: Int = 0
    @State private var openAccountSection = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()     .tag(0)
                ScheduleView() .tag(1)
                MapView()      .tag(2)
                PhotosView(selectedTab: $selectedTab, openAccountSection: $openAccountSection)   .tag(3)
                InfoAccountView(openAccountSection: $openAccountSection)     .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea(edges: .bottom)

            HAATabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Custom Tab Bar
struct HAATabBar: View {
    @Binding var selectedTab: Int

    let tabs: [(icon: String, label: String)] = [
        ("house.fill",           "Home"),
        ("calendar",             "Schedule"),
        ("map.fill",             "Map"),
        ("photo.fill",           "Photos"),
        ("ellipsis.circle.fill", "More"),
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { i in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = i
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tabs[i].icon)
                            .font(.system(size: 19, weight: selectedTab == i ? .semibold : .regular))
                            .scaleEffect(selectedTab == i ? 1.1 : 1.0)
                        Text(tabs[i].label)
                            .font(.system(size: 8, weight: .medium, design: .rounded))
                            .tracking(0.4)
                    }
                    .foregroundColor(selectedTab == i ? HAA.Colors.gold : Color.white.opacity(0.4))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                    .padding(.bottom, 24)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
            }
        }
        .background(
            HAA.Colors.charcoal
                .overlay(
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(HAA.Colors.gold.opacity(0.2)),
                    alignment: .top
                )
        )
    }
}
