//
//  UICollectionView+EasyRegister.swift
//  SwiftPlusPlus
//
//  Created by Andrew J Wagner on 10/16/16.
//  Copyright © 2016 Drewag LLC. All rights reserved.
//

import UIKit

extension UICollectionView {
    public func registerCellWithType(_ type: UICollectionViewCell.Type) {
        let nibName = self.nibNameFromType(type)
        let bundle = Bundle(for: type)
        let nib = UINib(nibName: nibName, bundle: bundle)
        self.register(nib, forCellWithReuseIdentifier: nibName)
    }

    public func dequeueCell<CellType: UICollectionViewCell>(for indexPath: IndexPath) -> CellType {
        let identifier = self.nibNameFromType(CellType.self)
        return self.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! CellType
    }

    public func nibNameFromType(_ type: UICollectionViewCell.Type) -> String {
        let fullClassName = NSStringFromClass(type)
        return fullClassName.components(separatedBy: ".")[1]
    }
}
