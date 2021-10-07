//
//  ContentView.swift
//  Example
//
//  Created by Chris Ballinger on 10/5/21.
//

import SwiftUI
import FlowStacks
import Introspect

enum Screen: Equatable, CaseIterable {
    case screen1
    case screen2
    case screen3
    case screen4
    case screen5
    case screen6

    var title: String {
        let index = Self.allCases.firstIndex(of: self) ?? 0
        return "Screen \(index + 1)"
    }
}

final class NavigationCoordinator: ObservableObject {
    @Published var flow = NFlow<Screen>(root: .screen1) {
        didSet {
            print("flow update: \(flow.array)")
        }
    }

    func pushNext() {
        switch flow.array.last {
        case .screen1:
            flow.push(.screen2)
        case .screen3:
            flow.push(.screen5)
        case .screen4:
            flow.push(.screen5)
        case .screen2, .screen5, .screen6, .none:
            fatalError("Not supported")
        }
    }
}

struct ContentView: View {
    @StateObject var navigator: NavigationCoordinator = .init()

    var body: some View {
        NavigationView {
            NStack($navigator.flow) { screen in
                DetailScreen(screen: screen)
            }
        }
        .environmentObject(navigator)
    }
}

struct DetailScreen: View {
    @EnvironmentObject var navigator: NavigationCoordinator

    var screen: Screen

    var body: some View {
        Group {
            switch screen {
            case .screen1, .screen3, .screen4:
                Button("Push Next") {
                    navigator.pushNext()
                }
            case .screen2:
                LazyVStack(spacing: 20) {
                    Button("Push \(Screen.screen3.title)") {
                        navigator.flow.push(.screen3)
                    }
                    Button("Push \(Screen.screen4.title)") {
                        navigator.flow.push(.screen4)
                    }
                }
            case .screen5:
                Button("Replace root \(Screen.screen6.title)") {
                    navigator.flow.replaceNFlow(with: [.screen6])
                }
            case .screen6:
                Button("Replace root \(Screen.screen1.title)") {
                    navigator.flow.replaceNFlow(with: [.screen1])
                }
            }
        }
        .navigationTitle(screen.title)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
