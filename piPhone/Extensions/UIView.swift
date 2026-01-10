//
// Copyright (C) 2016-2019 Blink Mobile Shell Project
// This file contains parts of from an original project called Blink.
// If you want to know more about Blink, see <http://www.github.com/blinksh/blink>.
//
// Modified by Gentris Leci on 1/30/20.
//
// Copyright © 2019 Gentris Leci.
//
// This file is part of piPhone
//
// piPhone is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// piPhone is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with piPhone.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit

extension UIView {
    func dropSuperViewTouches() {
        if let superview = superview,
            let window = window,
            superview != window
        {
            if let recognizers = gestureRecognizers {
                for r in recognizers {
                    r.dropTouches()
                }
            }
            superview.dropSuperViewTouches()
        }
    }

    func dropTouches() {
        if let recognizers = gestureRecognizers {
            for r in recognizers {
                r.dropTouches()
            }
        }

        for view in subviews {
            view.dropTouches()
        }
    }
}
