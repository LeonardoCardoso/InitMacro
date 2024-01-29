import InitMacro

@Init
public struct Person {
    let name: String
    let age: Int
}

@Init(defaults: ["balance": 100.0])
public class BankAccount {
    var accountNumber: String
    var balance: Double
}

@Init(wildcards: ["title"])
public class Book {
    var title: String?
    var author: String?
}

@Init(public: false)
public struct Vector {
    var x: Double
    var y: Double
    var z: Double
}

@Init
public struct Car {
    var wheels: Int = 4
    var seats: Int = 5
}
