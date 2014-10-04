//
//  DatePickerCell.swift
//  Sapristi
//
//  Created by Stephane Kasriel on 9/26/14.
//  Copyright (c) 2014 Stephane Kasriel. All rights reserved.
//

import UIKit

class DatePickerCell: UITableViewCell {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var label: UILabel!
    var delegate: DateSettingsViewController?
    
    @IBAction func datePickerValueChanged(sender: UIDatePicker) {
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
