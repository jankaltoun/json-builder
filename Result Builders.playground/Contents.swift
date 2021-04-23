import Foundation

/// Model
protocol JSON {
    var json: String { get }
}

struct Obj: JSON {
    var fragments: [JSON]
    
    init(fragments: [JSON]) {
        self.fragments = fragments
    }
    
    /// Example B
    init(@JSONBuilder fragments: () -> Self) {
        self = fragments()
    }
    /// Example B
    
    var json: String {
        let contents = fragments
            .map { $0.json }
            .joined(separator: ", ")
        
        return "{\(contents)}"
    }
}

struct Arr: JSON {
    var fragments: [JSON]
    
    init(fragments: [JSON]) {
        self.fragments = fragments
    }
    
    /// Example C
    init(@JSONBuilder fragments: () -> Self) {
        self = fragments()
    }
    /// Example C
    
    var json: String {
        let contents = fragments
            .map { $0.json }
            .joined(separator: ", ")
        
        return "[\(contents)]"
    }
}

struct Key: JSON {
    let key: String
    let value: JSON?
    
    init(_ key: String, _ value: JSON?) {
        self.key = key
        self.value = value
    }
    
    var json: String {
        let jsonValue = value?.json ?? "null"
        
        return "\"\(key)\": \(jsonValue)"
    }
}

extension String: JSON {
    var json: String {
        "\"\(self)\""
    }
}

extension Int: JSON {
    var json: String {
        "\(self)"
    }
}

extension Double: JSON {
    var json: String {
        "\(self)"
    }
}

/// Result Builder
@resultBuilder
struct JSONBuilder {
    typealias Component = [JSON] // The internal type used to compose things together
    typealias Expression = JSON // One thing - String, JSON object, JSON array etc.
    
    static func buildBlock(_ components: Component...) -> Component {
        print("- buildBlock for: \(components)")
        
        return components.flatMap { $0 }
    }
    
    static func buildExpression(_ expression: Expression) -> Component {
        print("- buildExpression (Expression) for: \(expression)")
        
        return [expression]
    }
    
    /// Example E
    static func buildArray(_ components: [Component]) -> Component {
        print("- buildArray for: \(components)")
        
        return components.flatMap { $0 }
    }
    /// Example E
    
    /// Example F
    static func buildOptional(_ component: Component?) -> Component {
        print("- buildOptional for: \(component)")
        
        return component ?? []
    }
    /// Example F
    
    /// Example D
    static func buildExpression(_ expression: [Expression]) -> Component {
        print("- buildExpression ([Expression]) for: \(expression)")
        
        return [Arr(fragments: expression)]
    }
    /// Example D
    
    /// Example G
    static func buildEither(first component: Component) -> Component {
        print("- buildEither (first) for: \(component)")
        
        return component
    }
    
    static func buildEither(second component: Component) -> Component {
        print("- buildEither (second) for: \(component)")
        
        return component
    }
    /// Example G
    
    static func buildFinalResult(_ component: Component) -> Obj {
        print("- buildFinalResult (Object) for: \(component)")
        
        return Obj(fragments: component)
    }
    
    /// Example C
    static func buildFinalResult(_ component: Component) -> Arr {
        print("- buildFinalResult (Arr) for: \(component)")
        
        return Arr(fragments: component)
    }
    /// Example C
    
    /// Example H
    static func buildLimitedAvailability(_ component: [JSON]) -> [JSON] {
        print("- buildLimitedAvailability for: \(component)")
        
        return component
    }
    /// Example H
}

/// Test
/// Example G
enum BestAnimal: String, CaseIterable {
    case llama
    case alpaca
}
/// Example G

@JSONBuilder var test: Obj { // buildFinalResult
    /// Example A - Keys
    Key("example_a_1", "Hello!")
    Key("example_a_2", 69)
    Key("example_a_3", 4.20)
    Key("example_a_4", nil)
    /// Example A
    
    /// Example B - Object
    Key("example_b", Obj {
        Key("example_b_1", "Hello!")
    })
    /// Example B
    
    /// Example C - Array & direct use of JSON-conforming type
    Key("example_c", Arr {
        "Hello!"
    })
    /// Example C
    
    /// Example D - Array & Swift array
    Key("example_d", Arr {
        "example_d - arrays work too"
        
        [
            "example_d - array 1",
            "example_d - array 2",
            "example_d - array 3"
        ]
    })
    /// Example D
    
    /// Example E - Loops
    Key("example_e", Obj {
        for i in 1...2 {
            Key("example_e_loop_\(i)", "works")
        }
        
        Key("example_e_outside_of_loop", "works")
    })
    /// Example E
    
    /// Example F - If without else
    if true {
        Key("example_f_if", "needs buildOptional")
    }
    /// Example F
    
    /// Example G - if with else & switch
    if true {
        Key("example_g_if", "is true")
    } else {
        Key("example_g_else", "is false")
    }
    
    switch BestAnimal.allCases.randomElement()! {
    case .llama:
        Key("example_g_best", "llama")
    case .alpaca:
        Key("example_g_best", "alpaca")
    }
    /// Example G
    
    /// Example H - Limited availability
    if #available(macOS 11.0, iOS 14.0, *) {
        Key("example_h_available", "is available")
    } else {
        Key("example_h_unavailable", "is not available")
    }
    /// Example H
}

/// Raw

//print(test.json)

/// Pretty printed

let data = test.json.data(using: .utf8)!

let json = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers)
let jsonData = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)

print(String(decoding: jsonData, as: UTF8.self))
