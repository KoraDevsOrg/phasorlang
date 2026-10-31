package phasorlang.lexer;

import java.util.Objects;

public class Token {
    public final TokenType type;
    public final String lexeme;
    public final Object literal; // Can be Double, String, Boolean, ComplexLiteral, PhaseAngleLiteral
    public final int line;

    public Token(TokenType type, String lexeme, Object literal, int line) {
        this.type = type;
        this.lexeme = lexeme;
        this.literal = literal;
        this.line = line;
    }

    @Override
    public String toString() {
        return type + " " + lexeme + " " + (literal != null ? literal.toString() : "null");
    }

    /**
     * Represents a complex number literal (e.g., 10+5j, -2j).
     */
    public static class ComplexLiteral {
        public final double real;
        public final double imag;

        public ComplexLiteral(double real, double imag) {
            this.real = real;
            this.imag = imag;
        }

        @Override
        public String toString() {
            if (imag == 0) return String.format("%.4f", real);
            if (real == 0) return String.format("%.4fj", imag);
            return String.format("%.4f %c %.4fj", real, (imag > 0 ? '+' : '-'), Math.abs(imag));
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            ComplexLiteral that = (ComplexLiteral) o;
            return Double.compare(that.real, real) == 0 && Double.compare(that.imag, imag) == 0;
        }

        @Override
        public int hashCode() {
            return Objects.hash(real, imag);
        }
    }

    /**
     * Represents a phase angle literal (e.g., 100@30°, 5@0°).
     */
    public static class PhaseAngleLiteral {
        public final double magnitude;
        public final double angleDegrees;

        public PhaseAngleLiteral(double magnitude, double angleDegrees) {
            this.magnitude = magnitude;
            this.angleDegrees = angleDegrees;
        }

        @Override
        public String toString() {
            return String.format("%.4f@%.2f°", magnitude, angleDegrees);
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (o == null || getClass() != o.getClass()) return false;
            PhaseAngleLiteral that = (PhaseAngleLiteral) o;
            return Double.compare(that.magnitude, magnitude) == 0 && Double.compare(that.angleDegrees, angleDegrees) == 0;
        }

        @Override
        public int hashCode() {
            return Objects.hash(magnitude, angleDegrees);
        }
    }
}
