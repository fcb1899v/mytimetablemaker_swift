//
//  getDataButton.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/17.
//

import SwiftUI

struct getDataButton: View {
    
    @State private var alertType: AlertType = .select
    @State private var isGetDataAlert = false
    @ObservedObject private var firestoreviewmodel: FirestoreViewModel

    init(
        _ firestoreviewmodel: FirestoreViewModel
    ) {
        self.firestoreviewmodel = firestoreviewmodel
    }
    
    enum AlertType {
        case select
        case complete
    }
    
    var body: some View {

        Button(action: {
            isGetDataAlert = true
            alertType = .select
        }) {
            Text("Get saved data".localized)
            .font(.subheadline)
                .foregroundColor(.black)
            .padding(5)
        }
        .alert(isPresented: $isGetDataAlert) {
            switch alertType {
                case .select: return getDataSelectAlert
                case .complete: return getDataCompleteAlert
            }
        }
    }

    private var getDataSelectAlert: Alert {
        return Alert(
            title: Text("Get saved data".localized),
            message: Text("Overwritten current data?".localized),
            primaryButton: .cancel(Text("Cancel".localized)),
            secondaryButton: .default(Text("OK"),
                action: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        firestoreviewmodel.getFirestore()
                        alertType = .complete
                        isGetDataAlert = true
                    }
                }
            )
        )
    }
    
    private var getDataCompleteAlert: Alert {
        Alert(
            title: Text(firestoreviewmodel.title),
            message: Text(firestoreviewmodel.message),
            dismissButton: .default(Text("OK"))
        )
    }
}

struct getDataButton_Previews: PreviewProvider {
    static var previews: some View {
        let firestoreviewmodel = FirestoreViewModel()
        getDataButton(firestoreviewmodel)
    }
}
