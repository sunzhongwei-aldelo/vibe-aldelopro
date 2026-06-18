import SwiftUI

// MARK: - Data Model

struct ProductDetail {
    let name: String
    let price: String
    let mainImageName: String
    let thumbnailImageNames: [String]
    let description: String
    let tasteAndPreparation: String
    let promotions: String
}

// MARK: - DetailsView

struct DetailsView: View {
    let product: ProductDetail
    var onDismiss: (() -> Void)?

    var body: some View {
        GeometryReader { geometry in
            let containerWidth = min(geometry.size.width * 0.9, 1104)
            let containerHeight = min(geometry.size.height * 0.9, 918)
            let scale = min(containerWidth / 1104, containerHeight / 918)

            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    headerSection(scale: scale)

                    // Product Info
                    productInfoSection(scale: scale)

                    // Divider
                    Divider()
                        .padding(.horizontal, 24 * scale)
                        .padding(.top, 16 * scale)

                    // Scrollable Content Sections
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            sectionView(
                                title: "Product Description",
                                content: product.description,
                                scale: scale
                            )

                            Divider()
                                .padding(.horizontal, 24 * scale)

                            sectionView(
                                title: "Taste & Preparation",
                                content: product.tasteAndPreparation,
                                scale: scale
                            )

                            Divider()
                                .padding(.horizontal, 24 * scale)

                            sectionView(
                                title: "Promotions",
                                content: product.promotions,
                                scale: scale
                            )
                        }
                    }
                    .frame(maxHeight: .infinity)

            
                }
                .frame(width: containerWidth, height: containerHeight)
                .background(Color.white)
                .cornerRadius(16 * scale)
                .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 8)
            }
        }
    }

    // MARK: - Header

    @ViewBuilder
    private func headerSection(scale: CGFloat) -> some View {
        HStack {
            Text("Details")
                .font(.system(size: 32 * scale, weight: .medium))
                .foregroundColor(Color(hex: "#262626"))

            Spacer()

            Button(action: { onDismiss?() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16 * scale, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 32 * scale, height: 32 * scale)
            }
        }
        .padding(.horizontal, 24 * scale)
        .padding(.top, 24 * scale)
        .padding(.bottom, 16 * scale)
    }

    // MARK: - Product Info

    @ViewBuilder
    private func productInfoSection(scale: CGFloat) -> some View {
        HStack(alignment: .top, spacing: 16 * scale) {
            // Main Image
            RoundedRectangle(cornerRadius: 16 * scale)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 213 * scale, height: 213 * scale)
                .overlay(
                    Image(product.mainImageName)
                        .resizable()
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 16 * scale))
                )
                .clipped()

            // Thumbnails Column
            VStack(spacing: 8 * scale) {
                ForEach(Array(product.thumbnailImageNames.prefix(3).enumerated()), id: \.offset) { index, imageName in
                    RoundedRectangle(cornerRadius: 8 * scale)
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 45 * scale, height: 45 * scale)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8 * scale)
                                .stroke(
                                    index == 0 ? Color(hex: "#007CFF") : Color.clear,
                                    lineWidth: 2
                                )
                        )
                        .opacity(index == 0 ? 1.0 : 0.5)
                }
            }

            // Product Name & Price
            VStack(alignment: .leading, spacing: 8 * scale) {
                Text(product.name)
                    .font(.system(size: 28 * scale, weight: .medium))
                    .foregroundColor(Color(hex: "#262626"))
                    .textCase(.none)

                Text(product.price)
                    .font(.system(size: 20 * scale, weight: .medium))
                    .foregroundColor(Color(hex: "#262626"))
                    .opacity(0.7)
            }
            .padding(.top, 4 * scale)

            Spacer()
        }
        .padding(.horizontal, 24 * scale)
    }

    // MARK: - Section View

    @ViewBuilder
    private func sectionView(title: String, content: String, scale: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 8 * scale) {
            Text(title)
                .font(.system(size: 24 * scale, weight: .medium))
                .foregroundColor(Color(hex: "#262626"))
                .padding(.top, 16 * scale)

            Text(content)
                .font(.system(size: 20 * scale, weight: .regular))
                .foregroundColor(Color(hex: "#595959"))
                .lineSpacing(12 * scale)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 16 * scale)
        }
        .padding(.horizontal, 24 * scale)
    }

    // MARK: - Bottom Buttons

    @ViewBuilder
    private func bottomButtons(scale: CGFloat) -> some View {
        HStack(spacing: 16 * scale) {
            Button(action: {}) {
                Text("Add to Order")
                    .font(.system(size: 20 * scale, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64 * scale)
                    .background(Color(hex: "#007CFF"))
                    .cornerRadius(12 * scale)
            }

            Button(action: {}) {
                Text("Cancel")
                    .font(.system(size: 20 * scale, weight: .medium))
                    .foregroundColor(Color(hex: "#262626"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 64 * scale)
                    .background(Color(hex: "#F5F5F5"))
                    .cornerRadius(12 * scale)
            }
        }
        .padding(.horizontal, 24 * scale)
        .padding(.bottom, 24 * scale)
        .padding(.top, 12 * scale)
    }
}

// Color(hex:) is defined in DesignTokens.swift

// MARK: - Preview

#Preview {
    DetailsView(
        product: ProductDetail(
            name: "Orange Juice",
            price: "From $5.00",
            mainImageName: "placeholder_product",
            thumbnailImageNames: ["thumb1", "thumb2", "thumb3"],
            description: "Made from premium imported oranges, freshly squeezed daily. No added sugar or water — just 100% pure juice. Rich in vitamin C and naturally refreshing.",
            tasteAndPreparation: "Flavor Profile: Sweet with a hint of tartness, rich citrus aroma, and smooth texture\nPreparation Method: Freshly squeezed to order, with pulp and natural fibers retained\nTemperature Options: Iced / Room Temperature\nSweetness Levels: No Sugar / Light / Medium",
            promotions: "Buy 1 Get 2nd at 50% Off (Limited Time)\nMembers enjoy 2 free juice vouchers monthly\nLeave a review to earn reward points for free drinks"
        ),
        onDismiss: {}
    )
    .frame(width: 675, height:600)
}
