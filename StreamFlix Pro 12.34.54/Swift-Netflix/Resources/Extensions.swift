


import Foundation

extension String {
    func capitalizeFirstLetter() -> String {
        var result: String = ""
        let name = self.split(separator: " ")
        for s in name {
            result += s.prefix(1).uppercased() + s.lowercased().dropFirst() + " "
        }
        return result
    }
}
