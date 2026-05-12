//
//  RepositoryRowView.swift
//  MVVMSwiftUI
//

import SwiftUI

struct RepositoryRowView: View {
    let repository: GitHubRepo

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(repository.name)
                .font(.headline)

            Text(repository.owner.login)
                .font(.caption)
                .foregroundStyle(.secondary)

            if let description = repository.description, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}
