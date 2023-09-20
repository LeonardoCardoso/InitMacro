import Foundation
#if canImport(InitMacro)
import InitMacro
#endif
#if canImport(InitMacroImplementation)
/// Macros targets can't be imported when the package is ran in systems other than macOS
@testable import InitMacroImplementation
#endif
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class InitMacroTests: XCTestCase {
    #if canImport(InitMacroImplementation)
    private let macros = [
        "Init": InitMacro.self,
    ]
    #endif

    func test_initMacro_asClass_expandsCorrectly() throws {
        #if canImport(InitMacroImplementation)
        assertMacroExpansion(
            """
            @Init
            public final class Test {
                let age: Int
                let cash: Double?
                let name: String
            }
            """,
            expandedSource:
            """

            public final class Test {
                let age: Int
                let cash: Double?
                let name: String

                public init(
                    age: Int,
                    cash: Double?,
                    name: String
                ) {
                    self.age = age
                    self.cash = cash
                    self.name = name
                }
            }
            """,
            macros: macros
        )
        #endif
    }

    func test_initMacro_asClassWithDefaults_expandsCorrectly() throws {
        #if canImport(InitMacroImplementation)
        assertMacroExpansion(
            """
            @Init(defaults: ["age": 21, "cash": nil, "name": "Leo"])
            public final class Test {
                let age: Int
                let cash: Double?
                let name: String
            }
            """,
            expandedSource:
            """

            public final class Test {
                let age: Int
                let cash: Double?
                let name: String

                public init(
                    age: Int = 21,
                    cash: Double? = nil,
                    name: String = "Leo"
                ) {
                    self.age = age
                    self.cash = cash
                    self.name = name
                }
            }
            """,
            macros: macros
        )
        #endif
    }

    func test_initMacro_asClassWithUnderscored_expandsCorrectly() throws {
        #if canImport(InitMacroImplementation)
        assertMacroExpansion(
            """
            @Init(wildcards: ["name", "cash"])
            public final class Test {
                let age: Int
                let cash: Double?
                let name: String
            }
            """,
            expandedSource:
            """

            public final class Test {
                let age: Int
                let cash: Double?
                let name: String

                public init(
                    age: Int,
                    _ cash: Double?,
                    _ name: String
                ) {
                    self.age = age
                    self.cash = cash
                    self.name = name
                }
            }
            """,
            macros: macros
        )
        #endif
    }

    func test_initMacro_asClassWithDefaultsAndUnderscored_expandsCorrectly() throws {
        #if canImport(InitMacroImplementation)
        assertMacroExpansion(
            """
            @Init(
                defaults: ["age": 21, "name": "Leo"],
                wildcards: ["age", "cash"]
            )
            public final class Test {
                let age: Int
                let cash: Double?
                let name: String
            }
            """,
            expandedSource:
            """

            public final class Test {
                let age: Int
                let cash: Double?
                let name: String

                public init(
                    _ age: Int = 21,
                    _ cash: Double?,
                    name: String = "Leo"
                ) {
                    self.age = age
                    self.cash = cash
                    self.name = name
                }
            }
            """,
            macros: macros
        )
        #endif
    }

    func test_initMacro_asClassWithDefaultsArray_expandsCorrectly() throws {
        #if canImport(InitMacroImplementation)
        assertMacroExpansion(
            """
            @Init(defaults: ["removeTraits": [AccessibilityTraits.isButton]])
            public struct AccessibilityInformation {
                public let id: String
                public let description: String
                public let traits: AccessibilityTraits
                public let removeTraits: AccessibilityTraits

                public static let unknown = "unknown"
            }
            """,
            expandedSource:
            """

            public struct AccessibilityInformation {
                public let id: String
                public let description: String
                public let traits: AccessibilityTraits
                public let removeTraits: AccessibilityTraits

                public static let unknown = "unknown"

                public init(
                    id: String,
                    description: String,
                    traits: AccessibilityTraits,
                    removeTraits: AccessibilityTraits = [AccessibilityTraits.isButton]
                ) {
                    self.id = id
                    self.description = description
                    self.traits = traits
                    self.removeTraits = removeTraits
                }
            }
            """,
            macros: macros
        )
        #endif
    }

    func test_initMacro_asClassWithEscapingClosure_expandsCorrectly() throws {
        #if canImport(InitMacroImplementation)
        assertMacroExpansion(
            """
            @Init
            public struct AccessibilityInformation {
                public let id: String
                public let description: String
                public let traits: AccessibilityTraits
                public let action: () -> Void
            }
            """,
            expandedSource:
            """

            public struct AccessibilityInformation {
                public let id: String
                public let description: String
                public let traits: AccessibilityTraits
                public let action: () -> Void

                public init(
                    id: String,
                    description: String,
                    traits: AccessibilityTraits,
                    action: @escaping () -> Void
                ) {
                    self.id = id
                    self.description = description
                    self.traits = traits
                    self.action = action
                }
            }
            """,
            macros: macros
        )
        #endif
    }

    func test_initMacro_asClassWithOptionalEscapingClosure_expandsCorrectly() throws {
        #if canImport(InitMacroImplementation)
        assertMacroExpansion(
            """
            @Init
            public struct AccessibilityInformation {
                public let id: String
                public let description: String
                public let traits: AccessibilityTraits
                public let action: (() -> Void)?
            }
            """,
            expandedSource:
            """

            public struct AccessibilityInformation {
                public let id: String
                public let description: String
                public let traits: AccessibilityTraits
                public let action: (() -> Void)?

                public init(
                    id: String,
                    description: String,
                    traits: AccessibilityTraits,
                    action: (() -> Void)?
                ) {
                    self.id = id
                    self.description = description
                    self.traits = traits
                    self.action = action
                }
            }
            """,
            macros: macros
        )
        #endif
    }

    func test_initMacro_asStruct_expandsCorrectly() throws {
        #if canImport(InitMacroImplementation)
        assertMacroExpansion(
            """
            @Init
            public struct RandomPoint {
                let x: Int
                var y: Int
            }
            """,
            expandedSource:
            """

            public struct RandomPoint {
                let x: Int
                var y: Int

                public init(
                    x: Int,
                    y: Int
                ) {
                    self.x = x
                    self.y = y
                }
            }
            """,
            macros: macros
        )
        #endif
    }

    func test_initMacro_asStructWithComputedProperty_expandsCorrectly() throws {
        #if canImport(InitMacroImplementation)
        assertMacroExpansion(
            """
            @Init(public: false)
            public struct RandomPoint {
                let x: Int
                var y: Int
                var xPlusY: Int { x + y }
            }
            """,
            expandedSource:
            """

            public struct RandomPoint {
                let x: Int
                var y: Int
                var xPlusY: Int { x + y }

                init(
                    x: Int,
                    y: Int
                ) {
                    self.x = x
                    self.y = y
                }
            }
            """,
            macros: macros
        )
        #endif
    }

    func test_initMacro_asStructWithAccessors_expandsCorrectly() throws {
        #if canImport(InitMacroImplementation)
        assertMacroExpansion(
            """
            @Init(public: false)
            public struct RandomPoint {
                let x: Int
                var y: Int
                var displayResult: Bool
                var isSelected: Bool {
                    get {
                        displayResult
                    }
                    set {
                        displayResult = newValue
                    }
                }
            }
            """,
            expandedSource:
            """

            public struct RandomPoint {
                let x: Int
                var y: Int
                var displayResult: Bool
                var isSelected: Bool {
                    get {
                        displayResult
                    }
                    set {
                        displayResult = newValue
                    }
                }

                init(
                    x: Int,
                    y: Int,
                    displayResult: Bool
                ) {
                    self.x = x
                    self.y = y
                    self.displayResult = displayResult
                }
            }
            """,
            macros: macros
        )
        #endif
    }

    func test_initMacro_asStructWithStaticAccessors_expandsCorrectly() throws {
        #if canImport(InitMacroImplementation)
        assertMacroExpansion(
            """
            @Init(public: false)
            public struct RandomPoint {
                static let x: Int
                var y: Int
                static var displayResult: Bool
                var isSelected: Bool {
                    get {
                        displayResult
                    }
                    set {
                        displayResult = newValue
                    }
                }
            }
            """,
            expandedSource:
            """

            public struct RandomPoint {
                static let x: Int
                var y: Int
                static var displayResult: Bool
                var isSelected: Bool {
                    get {
                        displayResult
                    }
                    set {
                        displayResult = newValue
                    }
                }

                init(
                    x: Int,
                    y: Int,
                    displayResult: Bool
                ) {
                    Self.x = x
                    self.y = y
                    Self.displayResult = displayResult
                }
            }
            """,
            macros: macros
        )
        #endif
    }

    func test_initMacro_asStructNotPublic_expandsCorrectly() throws {
        #if canImport(InitMacroImplementation)
        assertMacroExpansion(
            """
            @Init
            struct RandomPoint {
                let x: Int
                var y: Int
                var displayResult: Bool
            }
            """,
            expandedSource:
            """

            struct RandomPoint {
                let x: Int
                var y: Int
                var displayResult: Bool

                init(
                    x: Int,
                    y: Int,
                    displayResult: Bool
                ) {
                    self.x = x
                    self.y = y
                    self.displayResult = displayResult
                }
            }
            """,
            macros: macros
        )
        #endif
    }
    
    func test_initMacro_implicitDefaults() throws {
        #if canImport(InitMacroImplementation)
        assertMacroExpansion(
            """
            @Init
            struct RandomPoint {
                let x: Int = 5
                var y: Int
                var displayResult: Bool = true
            }
            """,
            expandedSource:
            """

            struct RandomPoint {
                let x: Int = 5
                var y: Int
                var displayResult: Bool = true

                init(
                    y: Int,
                    displayResult: Bool = true
                ) {
                    self.y = y
                    self.displayResult = displayResult
                }
            }
            """,
            macros: macros
        )
        #endif
    }
}
