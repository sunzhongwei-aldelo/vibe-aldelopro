import SwiftUI

// MARK: - Create Size Group View
// Source: Frame 88884.svg (1104x911 design)
// Layout: Full screen, landscape + portrait adaptive

struct AddPizzaView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var groupName: String = ""
    @State private var sizeNames: [String] = [""]

    var body: some View {
        ZStack {
            // Page background (full screen)
            AppColors.pageBg.ignoresSafeArea()

            // Card panel (centered, max width constrained)
            cardContent
                .frame(maxWidth: 1104)
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.lg)
        }
    }

    // MARK: - Card Content

    private var cardContent: some View {
        VStack(spacing: 0) {
            headerSection
            scrollableForm
            footerButtons
        }
        .padding(Spacing.lg)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            Text("Create Size Group")
                .font(AppFont.tabletH1Medium)
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
            }
        }
        .padding(.bottom, Spacing.lg)
    }

    // MARK: - Scrollable Form (handles portrait / many items)

    private var scrollableForm: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Size Group Name
                requiredLabel("Size Group Name")
                inputField(text: $groupName, placeholder: "Size Group Name")

                // Size Name
                Text("Size Name")
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.top, Spacing.xs)

                // Size rows
                ForEach(sizeNames.indices, id: \.self) { index in
                    sizeRow(index: index)
                }

                // Add Size button
                addSizeButton
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, Spacing.xs)
            }
        }
        .frame(maxHeight: .infinity)
    }

    // MARK: - Size Row

    private func sizeRow(index: Int) -> some View {
        HStack(spacing: Spacing.sm) {
            TextField("Spec Name", text: $sizeNames[index])
                .font(AppFont.tabletBody2Regular)
                .foregroundColor(AppColors.inputText)
                .padding(.horizontal, Spacing.md)
                .frame(height: 64)
                .background(AppColors.inputBg)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))

            Button {
                deleteSizeAt(index)
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 64, height: 64)
                    .background(AppColors.inputBg)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
            }
        }
    }

    // MARK: - Add Size Button

    private var addSizeButton: some View {
        Button {
            sizeNames.append("")
        } label: {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "plus.square.fill")
                    .foregroundColor(AppColors.primaryNormal)
                Text("Add Size")
                    .font(AppFont.tabletButton3Medium)
                    .foregroundColor(AppColors.primaryNormal)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                    .stroke(AppColors.primaryNormal, lineWidth: 1)
            )
        }
    }

    // MARK: - Footer Buttons

    private var footerButtons: some View {
        HStack(spacing: Spacing.md) {
            Button {
                dismiss()
            } label: {
                Text("Back")
                    .font(AppFont.tabletButton3Medium)
                    .foregroundColor(AppColors.buttonSecondaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(AppColors.buttonSecondaryBg)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
            }

            Button {
                save()
            } label: {
                Text("Save")
                    .font(AppFont.tabletButton3Medium)
                    .foregroundColor(AppColors.buttonPrimaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(AppColors.buttonPrimaryBg)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
            }
        }
        .padding(.top, Spacing.lg)
    }

    // MARK: - Helpers

    private func requiredLabel(_ title: String) -> some View {
        HStack(spacing: 2) {
            Text("*")
                .font(AppFont.tabletBody3Regular)
                .foregroundColor(AppColors.errorNormal)
            Text(title)
                .font(AppFont.tabletBody3Regular)
                .foregroundColor(AppColors.textSecondary)
        }
    }

    private func inputField(text: Binding<String>, placeholder: String) -> some View {
        TextField(placeholder, text: text)
            .font(AppFont.tabletBody2Regular)
            .foregroundColor(AppColors.inputText)
            .padding(.horizontal, Spacing.md)
            .frame(height: 64)
            .background(AppColors.inputBg)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
    }

    // MARK: - Actions

    private func deleteSizeAt(_ index: Int) {
        guard sizeNames.count > 1 else { return }
        sizeNames.remove(at: index)
    }

    private func save() {
        // TODO: Save logic
        dismiss()
    }
}

#Preview {
    AddPizzaView()
}
