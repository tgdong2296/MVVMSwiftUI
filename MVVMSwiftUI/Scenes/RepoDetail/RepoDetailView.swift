//
//  RepoDetailView.swift
//  MVVMSwiftUI
//
//  Created by Giang Dong Trinh on 12/5/26.
//

import SwiftUI
import FactoryKit

struct RepoDetailView: View {

    @State var viewModel: RepoDetailViewModel

    var body: some View {
        CommonContainerView(viewState: viewModel.viewState) {
            contentView
        }
        .navigationTitle(viewModel.repository.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Content

    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                Divider()
                statsSection
                Divider()
                infoSection

                if let url = URL(string: viewModel.repository.htmlUrl) {
                    Link(destination: url) {
                        Label("Open in GitHub", systemImage: "safari")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .padding(.top, 8)
                }
            }
            .padding()
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.repository.owner.login)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(viewModel.repository.fullName)
                .font(.title3)
                .fontWeight(.semibold)

            if let description = viewModel.repository.description, !description.isEmpty {
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var statsSection: some View {
        HStack {
            statItem(
                icon: "star.fill",
                color: .yellow,
                value: viewModel.repository.stargazersCount.formatted(),
                label: "Stars"
            )
            Spacer()
            statItem(
                icon: "tuningfork",
                color: .blue,
                value: viewModel.repository.forksCount.formatted(),
                label: "Forks"
            )
            Spacer()
            statItem(
                icon: "exclamationmark.circle.fill",
                color: .red,
                value: viewModel.repository.openIssuesCount.formatted(),
                label: "Issues"
            )
        }
        .padding(.vertical, 8)
    }

    private func statItem(icon: String, color: Color, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title2)
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)

            if let updatedAt = viewModel.repository.updatedAt {
                infoRow(icon: "clock", label: "Last updated", value: formattedDate(updatedAt))
            }
            infoRow(icon: "number", label: "Repository ID", value: String(viewModel.repository.id))
        }
    }

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Label(label, systemImage: icon)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
        }
    }

    private func formattedDate(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: isoString) else { return isoString }
        let display = DateFormatter()
        display.dateStyle = .medium
        display.timeStyle = .short
        return display.string(from: date)
    }
}

// MARK: - Factory Registration

extension Container {
    func repoDetailView(repository: GitHubRepo) -> Factory<RepoDetailView> {
        Factory(self) {
            MainActor.assumeIsolated {
                RepoDetailView(viewModel: Container.shared.repoDetailViewModel(repository: repository).resolve())
            }
        }
    }
}
