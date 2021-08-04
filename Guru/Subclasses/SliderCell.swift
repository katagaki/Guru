//
//  SliderCell.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/28.
//

import UIKit

class SliderCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var stepper: UIStepper!
    
    public weak var sliderValueChangeHandler: HandlesCellSliderValueChange? = nil
    
    @IBAction func stepperChanged(_ sender: Any) {
        slider.setValue(Float(stepper.value), animated: true)
        valueChanged(newValue: Int(stepper.value))
    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        stepper.value = Double(slider.value)
        valueChanged(newValue: Int(slider.value))
    }
    
    public func value() -> Int {
        return Int(slider.value)
    }
    
    private func valueChanged(newValue: Int) {
        sliderValueChangeHandler?.handleCellValueChange(value: newValue, label: titleLabel)
        countLabel.text = "\(Int(newValue))"
    }
    
}
