//
//  FlowLayout.swift
//  strucc
//
//  Created by Alejandro Arjonilla Garcia on 28/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import UIKit

/// The heights are declared as constants outside of the class so they can be easily referenced elsewhere
struct CellConstants {
    static let normalWidth: CGFloat = 42.22
    static let normalHeight: CGFloat = 42.22
    static let centeredWidth: CGFloat = 70 // originally 80
    static let centeredHeight: CGFloat = 110
}

class CollectionViewFlowLayout: UICollectionViewFlowLayout {

    var callBack: ((IndexPath, CGFloat) -> Void)?

    /// Content Offset
    var centerOffset: CGFloat {
        get {
            return (collectionView!.bounds.width - CellConstants.centeredWidth) / 2
        }
    }

    /// Dragging offset (used to calculate which cell is selected)
    var dragOffset: CGFloat {
        get { return CellConstants.normalWidth }
    }

    var cache = [UICollectionViewLayoutAttributes]()

    /// Returns the width of the collection view
    var width: CGFloat {
        get { return collectionView!.bounds.width }
    }

    /// Returns the height of the collection view
    var height: CGFloat {
        get { return collectionView!.bounds.height }
    }

    /// Returns the number of items in the collection view
    var numberOfItems: Int {
        get { return collectionView!.numberOfItems(inSection: 0) }
    }

    // MARK: - UICollectionViewFlowLayout override

    /// Return the size of all the content in the collection view
    override var collectionViewContentSize: CGSize {
        let contentWidth: CGFloat = 2 * centerOffset + CellConstants.centeredWidth + (numberOfItems.cgFloat - 1) * CellConstants.normalWidth + numberOfItems.cgFloat * minimumInteritemSpacing
        return CGSize(width: contentWidth, height: height)
    }

    override func prepare() {

        if cache.isEmpty || cache.count != numberOfItems {
            for item in 0..<numberOfItems {
                let indexPath = IndexPath(item: item, section: 0)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                cache.append(attributes)
            }
            updateLayout(forBounds: (collectionView?.bounds)!)
        }

    }

    /// Used to ignore bounds change when auto scrolling to certain cell
    var ignoringBoundsChange: Bool = false

    func updateLayout(forBounds newBounds: CGRect) {

        //print(">>>> Update Frame")

        let deltaX: CGFloat = CellConstants.centeredWidth - CellConstants.normalWidth
        let deltaY: CGFloat = CellConstants.centeredHeight - CellConstants.normalHeight
        let leftSideInset: CGFloat = (newBounds.width - CellConstants.centeredWidth) / 2

        for attribute: UICollectionViewLayoutAttributes in cache {
            let row = attribute.indexPath.row
            let isFirst = row == 0
            let separator = isFirst ? 0: (minimumInteritemSpacing*row.cgFloat
            )
            let normalCellOffsetX: CGFloat = leftSideInset + CGFloat(attribute.indexPath.row) * CellConstants.normalWidth + separator
            let normalCellOffsetY: CGFloat = (newBounds.height - CellConstants.normalHeight) / 2

            let distanceBetweenCellAndBoundCenters = normalCellOffsetX - newBounds.midX + CellConstants.centeredWidth / 2

            let normalizedCenterScale = distanceBetweenCellAndBoundCenters / CellConstants.normalWidth

            let isCenterCell: Bool = fabsf(Float(normalizedCenterScale)) < 1.0
            let isNormalCellOnRightOfCenter: Bool = (normalizedCenterScale > 0.0) && !isCenterCell
            let isNormalCellOnLeftOfCenter: Bool = (normalizedCenterScale < 0.0) && !isCenterCell

            if isCenterCell {
                let incrementX: CGFloat = (1.0 - CGFloat(abs(Float(normalizedCenterScale)))) * deltaX
                let incrementY: CGFloat = (1.0 - CGFloat(abs(Float(normalizedCenterScale)))) * deltaY

                callBack?(attribute.indexPath, abs(normalizedCenterScale))

                let offsetX: CGFloat = normalizedCenterScale > 0 ? deltaX - incrementX : 0
                let offsetY: CGFloat = -incrementY / 2

                attribute.frame = CGRect(x: normalCellOffsetX + offsetX, y: normalCellOffsetY + offsetY, width: CellConstants.normalWidth + incrementX, height: CellConstants.normalHeight + incrementY)
            } else if isNormalCellOnRightOfCenter {
                attribute.frame = CGRect(x: normalCellOffsetX + deltaX, y: normalCellOffsetY, width: CellConstants.normalWidth, height: CellConstants.normalHeight)
                callBack?(attribute.indexPath, 1)
            } else if isNormalCellOnLeftOfCenter {
                attribute.frame = CGRect(x: normalCellOffsetX, y: normalCellOffsetY, width: CellConstants.normalWidth, height: CellConstants.normalHeight)
                callBack?(attribute.indexPath, 1)
            }
        }

    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        updateLayout(forBounds: newBounds)
        return !ignoringBoundsChange
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()

        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let itemIndex = round(proposedContentOffset.x / dragOffset)
        let xOffset = itemIndex * dragOffset
        return CGPoint(x: xOffset, y: 0)
    }
}
