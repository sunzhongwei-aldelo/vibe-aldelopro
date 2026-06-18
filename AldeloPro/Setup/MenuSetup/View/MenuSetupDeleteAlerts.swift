//
//  MenuSetupDeleteAlerts.swift
//  AldeloPro
//
//  Created by jiangxia on 2026/06/11.
//

import SwiftUI

/// 菜单删除确认弹窗（删除单个 Item / 删除分组及其下属 Items）。
/// 以 overlay 形式叠加在 MenuSetupView 之上，逻辑与视觉与原 inline overlay 完全一致。
struct MenuSetupDeleteAlerts: ViewModifier {
    let viewModel: MenuSetupViewModel

    func body(content: Content) -> some View {
        content
            .overlay {
                if let item = viewModel.itemToDelete {
                    AldeloAlert(
                        style: .warning,
                        title: "Delete \(item.name)?",
                        confirmTitle: "Delete",
                        onConfirm: {
                            viewModel.confirmDeleteItem(item)
                        },
                        onCancel: {
                            viewModel.itemToDelete = nil
                        }
                    )
                }
            }
            .overlay {
                if let item = viewModel.pendingItemToDelete {
                    AldeloAlert(
                        style: .warning,
                        title: "Delete \(item.name)?",
                        confirmTitle: "Delete",
                        onConfirm: {
                            viewModel.confirmDeletePendingItem(item)
                        },
                        onCancel: {
                            viewModel.pendingItemToDelete = nil
                        }
                    )
                }
            }
            .overlay {
                if let group = viewModel.groupToDelete {
                    deleteGroupAlert(group: group)
                }
            }
    }

    private func deleteGroupAlert(group: SetupMenuGroup) -> some View {
        let itemCount = viewModel.itemsForGroup(groupId: group.id).count
        return AldeloAlert(
            style: .notice,
            title: "Delete \(group.name) Group?",
            confirmTitle: "Delete",
            cancelTitle: "Cancel",
            confirmColor: AppColors.errorNormal,
            onConfirm: {
                viewModel.confirmDeleteGroup(group)
            },
            onCancel: {
                viewModel.groupToDelete = nil
            }
        ) {
            VStack(alignment: .leading, spacing: Spacing.md) {
                if itemCount > 0 {
                    Text("\(itemCount) Items Exist Under This Group.")
                        .font(AppFont.tabletBody3Regular)
                        .foregroundColor(AppColors.textSecondary)

                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "checkmark.square.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.primaryNormal)
                        Text("Permanently Delete All \(itemCount) Items")
                            .font(AppFont.tabletBody3Regular)
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
        }
    }
}

extension View {
    func menuSetupDeleteAlerts(viewModel: MenuSetupViewModel) -> some View {
        modifier(MenuSetupDeleteAlerts(viewModel: viewModel))
    }
}
