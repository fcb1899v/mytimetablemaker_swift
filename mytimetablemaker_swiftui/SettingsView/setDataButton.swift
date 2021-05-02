//
//  setDataButton.swift
//  mytimetablemaker_swiftui
//
//  Created by 中島正雄 on 2021/03/19.
//

import SwiftUI

struct setDataButton: View {
    
    @State private var alertType: AlertType = .select
    @State private var isSetDataAlert = false
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
            isSetDataAlert = true
            alertType = .select
        }) {
            Text("Save current data".localized)
            .font(.subheadline)
            .foregroundColor(.black)
            .padding(5)
        }.alert(isPresented: $isSetDataAlert) {
            switch alertType {
                case .select: return setDataSelectAlert
                case .complete: return setDataCompleteAlert
            }
        }
    }

    private var setDataSelectAlert: Alert {
        return Alert(
            title: Text("Save current data".localized),
            message: Text("Overwritten saved data?".localized),
            primaryButton: .cancel(Text("Cancel".localized)),
            secondaryButton: .default(Text("OK"),
                action: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        firestoreviewmodel.setFirestore()
                        alertType = .complete
                        isSetDataAlert = true
                    }
                }
            )
        )
    }
    
    private var setDataCompleteAlert: Alert {
        Alert(
            title: Text(firestoreviewmodel.title),
            message: Text(firestoreviewmodel.message),
            dismissButton: .default(Text("OK"))
        )
    }
}

struct setDataButton_Previews: PreviewProvider {
    static var previews: some View {
        let firestoreviewmodel = FirestoreViewModel()
        setDataButton(firestoreviewmodel)
    }
}


