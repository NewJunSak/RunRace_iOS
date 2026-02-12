//
//  MatchmakerView.swift
//  RunRace
//
//  Created by BOMBSGIE on 2/12/26.
//

import SwiftUI
import GameKit

struct MatchmakerView: UIViewControllerRepresentable {
    @Binding var matchMode: MatchmakerMode?
    
    private let onMatchFound: (GKMatch?) -> Void
    
    func makeUIViewController(context: Context) -> GKMatchmakerViewController {
        var matchMakerViewController: GKMatchmakerViewController?
        
        switch matchMode {
        case .invite(let invite):
            matchMakerViewController = GKMatchmakerViewController(invite: invite)
        case .request(let request):
            matchMakerViewController = GKMatchmakerViewController(matchRequest: request)
        case .none:
            return GKMatchmakerViewController()
        }
        
        guard let matchMakerViewController else { return GKMatchmakerViewController() }
        matchMakerViewController.matchmakerDelegate = context.coordinator
        
        return matchMakerViewController
    }
    
    func updateUIViewController(_ uiViewController: GKMatchmakerViewController, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
}

// MARK: - Coordinator

extension MatchmakerView {
    final class Coordinator: NSObject, GKMatchmakerViewControllerDelegate {
        private var parent: MatchmakerView
        
        init(parent: MatchmakerView) {
            self.parent = parent
        }
        
        // GKMatchmakerViewController의 시작 버튼이 눌렸을 때 호출되는 메소드
        func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        }
        
        func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        }
        
        func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: any Error) {
            
        }
    }
}
