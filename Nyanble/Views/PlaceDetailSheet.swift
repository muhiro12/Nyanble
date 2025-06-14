//
//  PlaceDetailSheet.swift
//  Nyanble
//
//  Created by Hiromu Nakano on 2025/06/14.
//

import SwiftUI

struct PlaceDetailSheet: View {
    let place: RecommendedPlace
    var onSaveFavorite: () -> Void

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text(place.name)
                    .font(.title)
                    .bold()
                Text(place.detail)
                    .font(.body)
                Spacer()
                Button {
                    onSaveFavorite()
                } label: {
                    Label("お気に入り保存", systemImage: "star.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("詳細")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        onSaveFavorite()
                    }
                }
            }
        }
    }
}
