import SwiftDiagnostics

enum InitMacroDiagnostic: Error,
                          DiagnosticMessage {
    case notAsClass(String)
    case notAsStruct(String)

    private var rawValue: String {
        switch self {
        case let .notAsClass(macro):
            return "notAsClass_\(macro)"
        case let .notAsStruct(macro):
            return "notAsStruct_\(macro)"
        }
    }

    // MARK: - DiagnosticMessage
    var severity: DiagnosticSeverity { .error }

    var message: String {
        switch self {
        case let .notAsClass(macro):
            return "'@\(macro)' can only be applied to a class."
        case let .notAsStruct(macro):
            return "'@\(macro)' can only be applied to a struct."
        }
    }

    var diagnosticID: MessageID {
        .init(domain: "InitMacroImplementation", id: rawValue)
    }
}
