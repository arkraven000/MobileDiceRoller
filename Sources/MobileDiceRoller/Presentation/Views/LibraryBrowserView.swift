//
//  LibraryBrowserView.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import SwiftUI

/// Library browser view with pagination and search
///
/// Features:
/// - LazyVStack for virtual scrolling (performance)
/// - Pull-to-refresh
/// - Infinite scroll pagination
/// - Full-text search
struct LibraryBrowserView: View {
    @Bindable var viewModel: LibraryViewModel
    @State private var selectedTab: Tab = .weapons

    enum Tab {
        case weapons
        case defenders
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Picker
                Picker("Library Type", selection: $selectedTab) {
                    Text("Weapons").tag(Tab.weapons)
                    Text("Defenders").tag(Tab.defenders)
                }
                .pickerStyle(.segmented)
                .padding()

                // Content
                switch selectedTab {
                case .weapons:
                    WeaponsListView(viewModel: viewModel)
                case .defenders:
                    DefendersListView(viewModel: viewModel)
                }
            }
            .navigationTitle("Library")
            .searchable(text: $viewModel.searchQuery)
            .onChange(of: viewModel.searchQuery) { _, newValue in
                Task {
                    switch selectedTab {
                    case .weapons:
                        await viewModel.searchWeapons(newValue)
                    case .defenders:
                        await viewModel.searchDefenders(newValue)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await viewModel.refresh()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .task {
                await viewModel.loadWeapons()
                await viewModel.loadDefenders()
            }
        }
    }
}

// MARK: - Weapons List

private struct WeaponsListView: View {
    @Bindable var viewModel: LibraryViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredWeapons, id: \.id) { weapon in
                    WeaponRow(weapon: weapon) {
                        Task {
                            await viewModel.cloneWeapon(weapon)
                        }
                    } onDelete: {
                        Task {
                            await viewModel.deleteWeapon(weapon)
                        }
                    }
                }

                // Load more button
                if viewModel.hasMoreWeapons && !viewModel.isLoading {
                    Button("Load More") {
                        Task {
                            await viewModel.loadWeapons()
                        }
                    }
                    .padding()
                }

                // Loading indicator
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }
            }
            .padding()
        }
        .refreshable {
            await viewModel.loadWeapons(reset: true)
        }
    }
}

// MARK: - Defenders List

private struct DefendersListView: View {
    @Bindable var viewModel: LibraryViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredDefenders, id: \.id) { defender in
                    DefenderRow(defender: defender) {
                        Task {
                            await viewModel.cloneDefender(defender)
                        }
                    } onDelete: {
                        Task {
                            await viewModel.deleteDefender(defender)
                        }
                    }
                }

                // Load more button
                if viewModel.hasMoreDefenders && !viewModel.isLoading {
                    Button("Load More") {
                        Task {
                            await viewModel.loadDefenders()
                        }
                    }
                    .padding()
                }

                // Loading indicator
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }
            }
            .padding()
        }
        .refreshable {
            await viewModel.loadDefenders(reset: true)
        }
    }
}

// MARK: - Row Components

private struct WeaponRow: View {
    let weapon: Weapon
    let onClone: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            WeaponSummaryCard(weapon: weapon)

            VStack(spacing: 8) {
                Button(action: onClone) {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.bordered)

                Button(action: onDelete) {
                    Image(systemName: "trash")
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
        }
    }
}

private struct DefenderRow: View {
    let defender: Defender
    let onClone: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            DefenderSummaryCard(defender: defender)

            VStack(spacing: 8) {
                Button(action: onClone) {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.bordered)

                Button(action: onDelete) {
                    Image(systemName: "trash")
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
        }
    }
}

#Preview {
    LibraryBrowserView(
        viewModel: LibraryViewModel(
            weaponRepository: WeaponRepository(database: DatabaseService(
                keychainManager: KeychainManager(),
                configuration: DatabaseConfiguration()
            )),
            defenderRepository: DefenderRepository(database: DatabaseService(
                keychainManager: KeychainManager(),
                configuration: DatabaseConfiguration()
            ))
        )
    )
}
