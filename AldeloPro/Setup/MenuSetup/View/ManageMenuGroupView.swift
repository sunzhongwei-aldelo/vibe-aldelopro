//
//  ManageMenuGroupView.swift
//  AldeloPro
//
//  Created by jiangxia on 2026/06/08.
//

import SwiftUI

struct ManageMenuGroupView: View {
    // MARK: - Layout Constants
    private enum Layout {
        /// 滚动区底部预留高度 = 键盘高度 - 此值。弹窗本身不随键盘上移
        /// （见 `.ignoresSafeArea(.keyboard)`），靠这段留白让最后几行能滚到键盘之上；
        /// 60 抵掉弹窗底部 padding，避免留白过厚。
        static let keyboardBottomInsetTrim: CGFloat = 60
        /// 触发 scrollTo 前的等待，让键盘弹起 / 布局变化先落定，scrollTo 才算得准。
        static let scrollSettleDelay: Duration = .milliseconds(50)
        /// 滚动动画时长，与键盘动画保持一致。
        static let scrollAnimationDuration: TimeInterval = 0.25
    }

    // MARK: - State
    @State private var groups: [SetupMenuGroup] = []
    @State private var keyboardHeight: CGFloat = 0
    /// 待删除分组；非 nil 时弹出删除确认弹窗。确认仅移除当前页面数据源，
    /// 真正同步到 menu setup 仍需点击底部 Confirm。
    @State private var groupToRemove: SetupMenuGroup?
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedGroupId: UUID?

    /// id → array index, rebuilt only when `groups` changes — turns the
    /// per-keystroke binding lookup from O(n) into O(1).
    private var groupIndex: [UUID: Int] {
        Dictionary(uniqueKeysWithValues: groups.enumerated().map { ($1.id, $0) })
    }

    // MARK: - Callbacks
    var existingGroups: [SetupMenuGroup]
    var focusGroupId: UUID?
    var onConfirm: ([SetupMenuGroup]) -> Void

    // MARK: - Init
    init(existingGroups: [SetupMenuGroup], focusGroupId: UUID? = nil, onConfirm: @escaping ([SetupMenuGroup]) -> Void) {
        self.existingGroups = existingGroups
        self.focusGroupId = focusGroupId
        self.onConfirm = onConfirm
        let items = existingGroups.isEmpty
            ? [SetupMenuGroup(name: "")]
            : existingGroups
        _groups = State(initialValue: items)
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            AppColors.mask
                .ignoresSafeArea()
                .onTapGesture {
                    if focusedGroupId != nil {
                        focusedGroupId = nil
                    } else {
                        dismiss()
                    }
                }

            dialogCard

            if let group = groupToRemove {
                removeGroupAlert(group: group)
            }
        }
        // 弹窗整体不随键盘上移；露出聚焦框靠下方滚动区的底部留白 + scrollTo。
        .ignoresSafeArea(.keyboard)
        .observingKeyboardHeight($keyboardHeight)
        .onAppear {
            if let id = focusGroupId {
                focusedGroupId = id
            }
        }
    }

    // MARK: - Dialog Card
    private var dialogCard: some View {
        VStack(spacing: 0) {
            headerSection
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    groupListContent
                        .padding(.bottom, scrollBottomInset)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: focusedGroupId) { _, newId in
                    // Tabbing between fields while the keyboard is already up:
                    // scroll now. On the first tap (keyboard still rising) the
                    // keyboardHeight handler does it instead, so the target is
                    // computed against the final layout — exactly one scroll.
                    guard let id = newId, keyboardHeight > 0 else { return }
                    scroll(proxy, to: id)
                }
                .onChange(of: keyboardHeight) { oldHeight, newHeight in
                    // Keyboard just came up: bring the focused field into view.
                    guard oldHeight == 0, newHeight > 0,
                          let id = focusedGroupId else { return }
                    scroll(proxy, to: id)
                }
            }
            bottomButtons
        }
        .background(
            // Dismiss-tap lives on the background layer, *behind* the content.
            // Hit-testing routes a tap on a TextField/Button to that control
            // (it sits in front), so switching focus between fields works and
            // never clears focus. Only taps that land on genuinely empty space
            // fall through to this layer and dismiss the keyboard.
            AppColors.card
                .onTapGesture { focusedGroupId = nil }
        )
        .cornerRadius(Spacing.md)
        .padding(.horizontal, 100)
        .padding(.vertical, 60)
    }

    /// 键盘弹起时给滚动区垫出的底部留白；收起时为 0。
    private var scrollBottomInset: CGFloat {
        keyboardHeight > 0 ? keyboardHeight - Layout.keyboardBottomInsetTrim : 0
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack {
            Text("Manage Menu Group")
                .font(AppFont.tabletH1Medium)
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.lg)
        .padding(.bottom, Spacing.md)
    }

    // MARK: - Group List Content
    private var groupListContent: some View {
        VStack(spacing: Spacing.md) {
            ForEach(Array(groups.enumerated()), id: \.element.id) { index, group in
                groupRow(index: index, group: group)
                    .id(group.id)
            }
            addNewGroupButton
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.lg)
    }

    // MARK: - Group Row
    private func groupRow(index: Int, group: SetupMenuGroup) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "line.3.horizontal")
                .font(AppFont.tabletH3Medium)
                .foregroundColor(AppColors.textTertiary)
                .frame(width: 32)

            Text("Group \(index + 1)")
                .font(AppFont.tabletBody2Regular)
                .foregroundColor(AppColors.textSecondary)
                .frame(width: 80, alignment: .leading)


            TextField("Enter Group \(index + 1) Name", text: bindingForGroup(id: group.id))
                .font(AppFont.tabletBody2Regular)
                .foregroundColor(AppColors.textPrimary)
                .padding(.horizontal, Spacing.md)
                .frame(height: 64)
                .background(AppColors.buttonSecondaryBg)
                .cornerRadius(AppRadius.Tablet.xs)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.xs)
                        .stroke(focusedGroupId == group.id ? AppColors.primaryNormal : Color.clear, lineWidth: 1)
                )
                .focused($focusedGroupId, equals: group.id)
                .onSubmit {
                    moveToNextField(currentId: group.id)
                }

            Button {
                // 点删除先收键盘（若该行正聚焦）；空行直接删除，不弹确认。
                focusedGroupId = nil
                if group.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    removeGroup(id: group.id)
                } else {
                    groupToRemove = group
                }
            } label: {
                Image(.frame3)
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 64, height: 64)
            }
            .buttonStyle(.plain)
            .background(AppColors.buttonSecondaryBg)

        }
        .padding(Spacing.md)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                .stroke(AppColors.line, lineWidth: 1)
        )
    }

    // MARK: - Add New Group Button
    private var addNewGroupButton: some View {
        Button {
            let newItem = SetupMenuGroup(name: "")
            groups.append(newItem)
            focusedGroupId = newItem.id
        } label: {
            HStack(spacing: Spacing.xs) {
                Text("+ Add New Group")
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.textPrimary)
            }
            .padding(.horizontal, Spacing.lg)
            .frame(height: 63)
            .background(AppColors.card)
            .cornerRadius(AppRadius.Tablet.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                    .stroke(AppColors.line, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Remove Group Alert

    /// 删除分组确认弹窗。Remove 仅移除当前页面数据源（groups），
    /// 不直接同步 menu setup —— 真正同步在底部 Confirm。
    private func removeGroupAlert(group: SetupMenuGroup) -> some View {
        let itemCount = group.items.count
        return AldeloAlert(
            style: .notice,
            title: "Remove \(group.name) Group?",
            message: itemCount > 0
                ? "\(itemCount) Items Exist Under This Group Will Also Be Removed When Confirm."
                : nil,
            confirmTitle: "Remove",
            cancelTitle: "Cancel",
            confirmColor: AppColors.errorNormal,
            onConfirm: {
                removeGroup(id: group.id)
                groupToRemove = nil
            },
            onCancel: {
                groupToRemove = nil
            }
        )
    }

    // MARK: - Bottom Buttons
    private var bottomButtons: some View {
        HStack(spacing: Spacing.md) {
            Button {
                dismiss()
            } label: {
                Text("Cancel")
                    .font(AppFont.tabletButton3Medium)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: 280)
                    .frame(height: 64)
                    .background(AppColors.buttonSecondaryBg)
                    .cornerRadius(AppRadius.Tablet.lg)
            }
            .buttonStyle(.plain)

            Button {
                let validGroups = groups.filter { !$0.name.isEmpty }
                onConfirm(validGroups)
                dismiss()
            } label: {
                Text("Confirm")
                    .font(AppFont.tabletButton3Medium)
                    .foregroundColor(AppColors.buttonPrimaryText)
                    .frame(maxWidth: 280)
                    .frame(height: 64)
                    .background(AppColors.buttonPrimaryBg)
                    .cornerRadius(AppRadius.Tablet.lg)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.lg)
    }

    // MARK: - Helpers

    /// Single source of scroll truth — one animation, fired from exactly one
    /// place per scenario (see the two onChange handlers above).
    private func scroll(_ proxy: ScrollViewProxy, to id: UUID) {
        Task { @MainActor in
            // 等键盘 / 布局落定后再滚，scrollTo 才算得准。
            try? await Task.sleep(for: Layout.scrollSettleDelay)
            withAnimation(.easeOut(duration: Layout.scrollAnimationDuration)) {
                proxy.scrollTo(id, anchor: .top)
            }
        }
    }

    private func bindingForGroup(id: UUID) -> Binding<String> {
        Binding(
            get: { groupIndex[id].map { groups[$0].name } ?? "" },
            set: { newValue in
                if let idx = groupIndex[id] {
                    // 只改名字，保留 items / sortOrder（删除弹窗的 item 数依赖 items）。
                    groups[idx].name = newValue
                }
            }
        )
    }

    private func moveToNextField(currentId: UUID) {
        guard let currentIndex = groups.firstIndex(where: { $0.id == currentId }) else { return }
        let nextIndex = currentIndex + 1
        if nextIndex < groups.count {
            focusedGroupId = groups[nextIndex].id
        } else {
            focusedGroupId = nil
        }
    }

    /// 确认后仅移除当前页面数据源；同步到 menu setup 由底部 Confirm 触发。
    private func removeGroup(id: UUID) {
        groups.removeAll { $0.id == id }
        if groups.isEmpty {
            groups.append(SetupMenuGroup(name: ""))
        }
    }
}

// MARK: - Preview

#Preview {
    ManageMenuGroupView(
        existingGroups: [
            SetupMenuGroup(name: "Burgers & Sandwiches"),
            SetupMenuGroup(name: "Beverages"),
            SetupMenuGroup(name: "Desserts")
        ],
        onConfirm: { _ in }
    )
}
