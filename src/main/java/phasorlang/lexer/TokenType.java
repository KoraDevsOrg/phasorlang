package phasorlang.lexer;

public enum TokenType {
    // Single-character tokens
    LEFT_PAREN, RIGHT_PAREN, LEFT_BRACE, RIGHT_BRACE,
    COMMA, DOT, MINUS, PLUS, SEMICOLON, SLASH, STAR, PERCENT,

    // One or two character tokens
    BANG, BANG_EQUAL,
    EQUAL, EQUAL_EQUAL,
    GREATER, GREATER_EQUAL,
    LESS, LESS_EQUAL,
    ARROW, // -> for function definitions, type hints, etc.
    COLON, // For type declarations, object literals
    POWER, // ** for exponentiation (e.g., 2**3)

    // Literals
    IDENTIFIER, STRING, NUMBER, BOOLEAN,
    COMPLEX_LITERAL, // e.g., 10+5j, -2j, 3.14 (imaginary part indicated by 'j' suffix)
    PHASE_ANGLE_LITERAL,    // e.g., 100@30°, 5@0° (phase angle indicated by '@' symbol)

    // Keywords
    AND, OR, NOT, // Logical operators
    IF, ELSE, ELIF, // Conditional statements
    FOR, WHILE, LOOP, // Loop constructs
    BREAK, CONTINUE, // Loop control
    FUN, RETURN, // Functions
    VAR, CONST, // Variable declarations
    CLASS, EXTENDS, SUPER, THIS, NEW, // Object-Oriented Programming
    TRUE, FALSE, NIL, // Boolean and null literals

    // PhasorLang Specific Keywords/Directives
    IMPORT, AS, // Module imports (import foo as bar)
    LIB, // Library declaration
    SCREEN, ACTION, // UI screen/action routing
    DRAW, FILL, LINE, CIRCLE, RECT, TEXT, BUTTON, // Basic UI Drawing primitives
    BACKGROUND, // For background drawing
    ASSERT, ASSERT_NEAR, ASSERT_SIMD, ASSERT_SOA, ASSERT_SOA_NEAR, // Testing assertions
    TRY, CATCH, PANIC, // Error handling
    VEC2, VEC3, VEC4, // Vector types (VEC3 is confirmed, 2 and 4 are potential future additions)
    SOA_ALLOC, SOA_LOAD, SOA_STORE, SOA_STEP_SIMD, SOA_INIT_VEL, // Structure of Arrays operations
    REGISTER, // For registering modules/languages in the polyglot hub
    HOST, WHITELIST, // Network security management terms

    // Built-in functions/accessors (could also be identifiers depending on context)
    MAG, ANGLE, REAL, IMAG, // Complex number accessors
    X, Y, Z, W, // Vector component accessors
    DOT, CROSS, NORM, // Vector operations

    EOF // End of file
}
