/// Generates a public initializer.
///
/// Example:
///
///   @Init(defaults: [:], wildcards: [], public: true)
///   public final class Test {
///       let age: Int
///       let cash: Double?
///       let name: String
///   }
///
/// produces
///
///    public final class Test {
///        let age: Int
///        let cash: Double?
///        let name: String
///
///        public init(
///            age: Int,
///            cash: Double?,
///            name: String
///        ) {
///            self.age = age
///            self.cash = cash
///            self.name = name
///        }
///    }
///
///    - Parameters:
///      - defaults: Dictionary containing defaults for the specificed properties.
///      - wildcards: Array containing the specificed properties that should be wildcards.
///      - public: The flag to indicate if the init is public or not.
@attached(member, names: named(init))
public macro Init(
    defaults: [String: Any] = [:],
    wildcards: [String] = [],
    public: Bool = true
) = #externalMacro(
    module: "InitMacroImplementation",
    type: "InitMacro"
)
