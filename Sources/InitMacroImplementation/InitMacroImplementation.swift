import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Generates a public initializer.
///
/// Example:
///
///     @Init(defaults: [:], wildcards: [], public: true)
///     public final class Test {
///         let age: Int
///         let cash: Double?
///         let name: String
///     }
///
/// produces
///
///     public final class Test {
///         let age: Int
///         let cash: Double?
///         let name: String
///
///         public init(
///             age: Int,
///             cash: Double?,
///             name: String
///         ) {
///             self.age = age
///             self.cash = cash
///             self.name = name
///         }
///     }
///
///    - Parameters:
///      - defaults: Dictionary containing defaults for the specificed properties.
///      - wildcards: Array containing the specificed properties that should be wildcards.
///      - public: The flag to indicate if the init is public or not.
struct InitMacro: MemberMacro {
    static func expansion(
        of attribute: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Only `struct` and `class` is suitable for this macro
        guard declaration.is(StructDeclSyntax.self) || declaration.is(ClassDeclSyntax.self) else {
            let message: DiagnosticMessage
            if !declaration.is(StructDeclSyntax.self) {
                message = InitMacroDiagnostic.notAsStruct("InitMacro")
            } else {
                message = InitMacroDiagnostic.notAsClass("InitMacro")
            }
            let error = Diagnostic(
                node: attribute._syntaxNode,
                message: message
            )
            context.diagnose(error)
            return []
        }

        var parameters = [String]()
        var assignments = [String]()
        var accessControlType = false

        if let decl = declaration.as(ClassDeclSyntax.self) {
            (parameters, assignments, accessControlType) = makeData(
                getAccessControls("", decl.modifiers),
                decl.memberBlock.members,
                decl.attributes
            )
        }
        if let decl = declaration.as(StructDeclSyntax.self) {
            (parameters, assignments, accessControlType) = makeData(
                getAccessControls("", decl.modifiers),
                decl.memberBlock.members,
                decl.attributes
            )
        }

        let initBody: ExprSyntax = "\(raw: assignments.joined(separator: "\n"))"

        let initDeclSyntax = try InitializerDeclSyntax(
            PartialSyntaxNodeString(
                stringLiteral: "\(accessControlType ? "public " : "")init(\n\(parameters.joined(separator: ",\n"))\n)"
            ),
            bodyBuilder: { initBody }
        )

        return ["\(raw: initDeclSyntax)"]
    }

    private static func makeData(
        _ accessControlPrefix: String,
        _ members: MemberDeclListSyntax,
        _ attributes: AttributeListSyntax?
    ) -> ([String], [String], Bool) {
        var defaults = [String: String]()
        var wildcards = [String]()

        // Get attributes for Init macro
        let attributes = getAttributes(attributes, "Init")?
            .argument?.as(TupleExprElementListSyntax.self)

        // Analyse the `defaults` parameter
        if let defaultsAttributes = attributes?
            .first(where: { "\($0)".contains("defaults") })?
            .expression.as(DictionaryExprSyntax.self)?
            .content.as(DictionaryElementListSyntax.self) {
            for attribute in defaultsAttributes {
                if let key = attribute.keyExpression.as(StringLiteralExprSyntax.self)?
                    .segments.first?.as(StringSegmentSyntax.self)?
                    .content {
                    defaults["\(key)"] = "\(attribute.valueExpression)"
                }
            }
        }

        // Analyse the `wildcards` parameter
        if let wildcardsAttributes = attributes?
            .first(where: { "\($0)".contains("wildcards") })?
            .expression.as(ArrayExprSyntax.self)?
            .elements.as(ArrayElementListSyntax.self) {
            for attribute in wildcardsAttributes {
                if let key = attribute.expression.as(StringLiteralExprSyntax.self)?
                    .segments.first?.as(StringSegmentSyntax.self)?
                    .content {
                    wildcards.append("\(key)")
                }
            }
        }

        // Analyse the `public` parameter
        var accessControlType = accessControlPrefix.contains("public")
        if let publicAttribute = attributes?
            .first(where: { "\($0)".contains("public") })?
            .expression.as(BooleanLiteralExprSyntax.self)?
            .booleanLiteral {
            accessControlType = "\(publicAttribute)" == "true"
        }

        var parameters = [String]()
        var assignments = [String]()

        for member in members {
            if let syntax = member.decl.as(VariableDeclSyntax.self),
               let bindings = syntax.bindings.as(PatternBindingListSyntax.self),
               let pattern = bindings.first?.as(PatternBindingSyntax.self),
               let identifier = (pattern.pattern.as(IdentifierPatternSyntax.self))?.identifier,
               let type = (pattern.typeAnnotation?.as(TypeAnnotationSyntax.self))?.type {

                let shouldUnderscoreParameter = wildcards.contains("\(identifier)")
                let identifierPrefix = "\(shouldUnderscoreParameter ? "_ " : "")"

                let shouldAddScaping = type.is(FunctionTypeSyntax.self)
                let typePrefix = "\(shouldAddScaping ? "@escaping " : "")"

                var parameter = "\(identifierPrefix)\(identifier): \(typePrefix)\(type)"
                if let defaultValue = defaults["\(identifier)"] {
                    parameter += " = " + "\(defaultValue)"
                }

                let memberAccessControl = getAccessControls("", syntax.modifiers)
                let memberAccessControlPrefix = (memberAccessControl.contains("static") ? "S" : "s") + "elf"

                let isComputedProperty = pattern.accessor?.is(CodeBlockSyntax.self) == true
                let isUsingAccessControls = pattern.accessor?.is(AccessorBlockSyntax.self) == true
                if !isComputedProperty, !isUsingAccessControls {
                    parameters.append(parameter)
                    assignments.append("\(memberAccessControlPrefix).\(identifier) = \(identifier)")
                }
            }
        }

        return (parameters, assignments, accessControlType)
    }

    private static func getAttributes(
        _ attributes: AttributeListSyntax?,
        _ key: String
    ) -> AttributeSyntax? {
        attributes?
            .first(where: { "\($0)".contains(key) })?
            .as(AttributeSyntax.self)
    }

    private static func getAccessControls(
        _ initialAccessControl: String,
        _ modifiers: ModifierListSyntax?
    ) -> String {
        var initialAccessControl = initialAccessControl
        modifiers?.forEach {
            if let accessControlType = $0.as(DeclModifierSyntax.self)?.name {
                initialAccessControl += "\(accessControlType.text) "
            }
        }
        return initialAccessControl
    }
}
