//
//  MenuSetupManualView.swift
//  AldeloPro
//
//  Created by jiangxia on 2026/06/11.
//

import SwiftUI

/// 菜单「手动搭建」界面（标题栏 + 分组/项目列表 + 空状态 + 底部按钮）。
struct MenuSetupManualView: View {
    let viewModel: MenuSetupViewModel
    let isNarrow: Bool
    var onPreviousStep: (() -> Void)?
    var onSaveAndNextStep: (() -> Void)?
    var onScanOrUpload: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            menuSetupTitleBar(isNarrow: isNarrow)
            if viewModel.menuGroups.isEmpty {
                Spacer()
                menuSetupEmptyState
                Spacer()
            } else {
                menuSetupGroupList(isNarrow: isNarrow)
                Spacer()
            }
            menuSetupBottomButtons
        }
    }

    // MARK: - Menu Setup 标题栏 + 操作按钮
    /// 横屏：标题与操作按钮同一行（按钮靠右）。
    /// 竖屏（iPad 竖屏 / iPhone 竖屏）：标题独占一行，按钮在下方一行横向可滚动，
    /// 避免窄屏横向放不下时挤压标题导致逐字换行。
    @ViewBuilder
    private func menuSetupTitleBar(isNarrow: Bool) -> some View {
        Group {
            if isNarrow {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    Text("Menu Setup")
                        .font(AppFont.tabletH1Medium)
                        .foregroundColor(AppColors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.sm) {
                            menuActionButtons
                        }
                    }
                }
            } else {
                HStack(spacing: Spacing.md) {
                    Text("Menu Setup")
                        .font(AppFont.tabletH1Medium)
                        .foregroundColor(AppColors.textPrimary)

                    Spacer()

                    HStack(spacing: Spacing.sm) {
                        menuActionButtons
                    }
                }
            }
        }
        .padding(.horizontal, isNarrow ? Spacing.lg : Spacing.xxxxxxxl)
        .padding(.top, Spacing.lg)
    }

    // MARK: - Menu Setup 操作按钮组（横竖屏共用）
    @ViewBuilder
    private var menuActionButtons: some View {
        menuSetupActionButton(icon: "AI Voice Chat", title: "Chat") {
            viewModel.presentedMethod = .aiVoiceChat
        }
        menuSetupActionButton(icon: "Scan or Upload", title: "Scan") {
            onScanOrUpload?()
        }
        menuSetupActionButton(icon: "Manually Add", title: "Menu Group") {
            viewModel.presentCreateGroup()
        }
        menuSetupAddItemButton
    }

    // MARK: - Menu Setup 操作按钮（通用）
    private func menuSetupActionButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                Image(icon)
                    .font(AppFont.tabletH3Medium)
                Text(title)
                    .font(AppFont.tabletH3Medium)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .foregroundColor(AppColors.textPrimary)
            .padding(.horizontal, Spacing.lg)
            .frame(height: 50)
            .background(AppColors.card)
            .cornerRadius(AppRadius.Tablet.xs)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.xs)
                    .stroke(AppColors.line, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Add Item 按钮（无 menu group 时禁用）
    private var menuSetupAddItemButton: some View {
        Button {
            viewModel.presentCreateItem(groupId: nil)
        } label: {
            HStack(spacing: Spacing.xs) {
                Image(viewModel.menuGroups.isEmpty ? "addMenuGray" : "addMenuBlue")
                    .font(AppFont.tabletH3Medium)
                Text("Add Item")
                    .font(AppFont.tabletH3Medium)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .foregroundColor(viewModel.menuGroups.isEmpty ? AppColors.buttonPrimaryText : AppColors.primaryNormal)
            .padding(.horizontal, Spacing.lg)
            .frame(height: 50)
            .background(viewModel.menuGroups.isEmpty ? AppColors.buttonDisabledBg : AppColors.card)
            .cornerRadius(AppRadius.Tablet.xs)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.xs)
                    .stroke(viewModel.menuGroups.isEmpty ? Color.clear : AppColors.primaryNormal, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(viewModel.menuGroups.isEmpty)
    }

    // MARK: - Menu Setup 空状态
    private var menuSetupEmptyState: some View {
        VStack(spacing: Spacing.md) {
            Image(.noMenuList)
                .font(.system(size: 48))
                .foregroundColor(AppColors.line)

            Text("Please Create A Menu Group Before Add Item")
                .font(AppFont.tabletBody2Regular)
                .foregroundColor(AppColors.textSecondary)

            Button {
                viewModel.presentCreateGroup()
            } label: {
                HStack(spacing: Spacing.xs) {
                    Image(.addMenuBlue)
                        .font(AppFont.tabletH3Medium)
                    Text("Add Menu Group")
                        .font(AppFont.tabletH3Medium)
                }
                .foregroundColor(AppColors.primaryNormal)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Menu Setup Group List
    private func menuSetupGroupList(isNarrow: Bool) -> some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: Spacing.md), count: 2)

        return ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: Spacing.md, pinnedViews: [.sectionHeaders]) {
                ForEach(viewModel.menuGroups) { group in
                    Section {
                        let items = viewModel.itemsForGroup(groupId: group.id)
                        if !items.isEmpty {
                            LazyVGrid(columns: columns, spacing: Spacing.md) {
                                ForEach(items) { item in
                                    menuItemCard(item: item)
                                }
                            }
                            .padding(.bottom, Spacing.xs)
                        }
                    } header: {
                        menuGroupRow(group: group, isNarrow: isNarrow)
                    }
                }
            }
            .padding(.horizontal, isNarrow ? Spacing.lg : Spacing.xxxxxxxl)
            .padding(.top, Spacing.md)
        }
    }

    // MARK: - Group Row
    private func menuGroupRow(group: SetupMenuGroup, isNarrow: Bool) -> some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Text(group.name)
                .font(AppFont.tabletH3Medium)
                .foregroundColor(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: Spacing.sm) {
                Button {
                    viewModel.presentCreateItem(groupId: group.id)
                } label: {
                    Image(.addItemBlack)
                        .font(AppFont.tabletH3Medium)
                        .foregroundColor(AppColors.textSecondary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Button {
                    viewModel.presentEditGroup(group)
                } label: {
                    Image(.frame2)
                        .font(AppFont.tabletH3Medium)
                        .foregroundColor(AppColors.textSecondary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Button {
                    viewModel.requestDeleteGroup(group)
                } label: {
                    Image(.frame3)
                        .font(AppFont.tabletH3Medium)
                        .foregroundColor(AppColors.textSecondary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, Spacing.xxs)
        .background(AppColors.pageBg)
    }

    // MARK: - Menu Item Card
    private func menuItemCard(item: SetupMenuItem) -> some View {
        let showDot = viewModel.aiAddedItemIds.contains(item.id)

        return HStack(spacing: Spacing.md) {
            MenuItemThumbnail(coverData: item.coverImageData)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(item.name)
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                Text("$ \(NSDecimalNumber(decimal: item.unitPrice).stringValue)")
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            HStack(spacing: Spacing.sm) {
                Button(action: {
                    viewModel.presentEditItem(item)
                }) {
                    Image(.frame2)
                        .font(AppFont.tabletH3Medium)
                        .foregroundColor(AppColors.textSecondary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Button(action: { viewModel.itemToDelete = item }) {
                    Image(.frame3)
                        .font(AppFont.tabletH3Medium)
                        .foregroundColor(AppColors.textSecondary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .frame(height: 100)
        .background(AppColors.card)
        .cornerRadius(AppRadius.Tablet.sm)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .stroke(AppColors.line, lineWidth: 1)
        )
        .overlay(alignment: .topLeading) {
            if showDot {
                Circle()
                    .fill(AppColors.primaryNormal)
                    .frame(width: 11, height: 11)
                    .offset(x: Spacing.md, y: Spacing.md)
            }
        }
    }

    // MARK: - Menu Setup 底部按钮
    private var menuSetupBottomButtons: some View {
        HStack(spacing: Spacing.xs) {
            Button {
                onPreviousStep?()
            } label: {
                Text("Previous Step")
                    .font(AppFont.tabletButton3Medium)
                    .foregroundColor(AppColors.buttonTextColor)
                    .frame(maxWidth: 382)
                    .controlHeight(64)
                    .background(AppColors.card)
                    .cornerRadius(AppRadius.Tablet.lg)
            }
            .buttonStyle(.plain)

            Button {
                onSaveAndNextStep?()
            } label: {
                Text("Save & Next Step")
                    .font(AppFont.tabletButton3Medium)
                    .foregroundColor(AppColors.buttonPrimaryText)
                    .frame(maxWidth: 382)
                    .controlHeight(64)
                    .background(AppColors.buttonPrimaryBg)
                    .cornerRadius(AppRadius.Tablet.lg)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.lg)
    }
}
#if DEBUG
@MainActor
private func _previewMenuSetupVM() -> MenuSetupViewModel {
    let viewModel = MenuSetupViewModel()
    let burgers = SetupMenuGroup(name: "Burgers & Sandwiches", sortOrder: 0)
    let beverages = SetupMenuGroup(name: "Beverages", sortOrder: 1)
    viewModel.updateGroups([burgers, beverages])

    func swatch(_ color: UIColor) -> Data {
        let size = CGSize(width: 160, height: 160)
        let image = UIGraphicsImageRenderer(size: size).image { ctx in
            color.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            UIColor.white.withAlphaComponent(0.85).setFill()
            ctx.cgContext.fillEllipse(in: CGRect(x: 50, y: 50, width: 60, height: 60))
        }
        return image.pngData() ?? Data()
    }

    viewModel.addItem(SetupMenuItem(name: "Ham & Egg Sandwich", groupId: burgers.id, unitPrice: 19.99, imageData: [swatch(.systemBrown)], coverImageIndex: 0))
    viewModel.addItem(SetupMenuItem(name: "Bacon Burger", groupId: burgers.id, unitPrice: 1.99))
    viewModel.addItem(SetupMenuItem(name: "Smoked Salmon Bagel", groupId: burgers.id, unitPrice: 5.50, imageData: [swatch(.systemOrange)], coverImageIndex: 0))
    viewModel.addItem(SetupMenuItem(name: "Cheese Burger", groupId: burgers.id, unitPrice: 1.99))
    viewModel.addItem(SetupMenuItem(name: "Club Sandwich", groupId: burgers.id, unitPrice: 8.25, imageData: [swatch(.systemRed)], coverImageIndex: 0))
    viewModel.addItem(SetupMenuItem(name: "Veggie Wrap", groupId: burgers.id, unitPrice: 6.75))
    viewModel.addItem(SetupMenuItem(name: "Milk", groupId: beverages.id, unitPrice: 1.99, imageData: [swatch(.systemBlue)], coverImageIndex: 0))
    viewModel.addItem(SetupMenuItem(name: "Coffee", groupId: beverages.id, unitPrice: 9.99))
    viewModel.addItem(SetupMenuItem(name: "Orange Juice", groupId: beverages.id, unitPrice: 3.50, imageData: [swatch(.systemGreen)], coverImageIndex: 0))
    viewModel.addItem(SetupMenuItem(name: "Iced Tea", groupId: beverages.id, unitPrice: 2.75))
    
    return viewModel
}

#Preview(traits: .landscapeLeft) {
    MenuSetupManualView(viewModel: _previewMenuSetupVM(), isNarrow: false)
}
#endif


