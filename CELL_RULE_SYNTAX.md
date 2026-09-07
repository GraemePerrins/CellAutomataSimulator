# Cellular Automata Rule Expression Syntax Specification

## 1. Overview & Evaluation

This document defines the formal grammar, semantics, and reference examples for the **Cell Rule Expression Syntax**. The syntax is designed for a 2D cellular automata simulation engine where each cell's next state ($1 = \text{ON}$, $0 = \text{OFF}$) is evaluated based on its current state and the states of its Moore neighborhood.

### 1.1 Neighborhood Mapping
Cells are evaluated relative to the target cell `C0`. The 8 surrounding neighbors are indexed `C1` through `C8` in row-major order:

```text
+------+------+------+
|  C1  |  C2  |  C3  |   (NW,   N,  NE)
+------+------+------+
|  C4  |  C0  |  C5  |   ( W,  Self,  E)
+------+------+------+
|  C6  |  C7  |  C8  |   (SW,   S,  SE)
+------+------+------+
```

* `C0`: The current cell being evaluated.
* `C1`–`C8`: The 8 adjacent neighbor cells.

### 1.2 Evaluation of Language Design & Syntax Rules

1. **Cell Reference Shorthand (`C0`–`C8`)**:
   * Cells are referenced directly by name: `C0`, `C1`, `C2`, ..., `C8` without function parentheses `()`.
   * Each cell reference directly resolves to its binary state integer (`0` or `1`), keeping expressions clean and uncluttered.

2. **Dual Logic Representation (Functional & Infix)**:
   * **Infix notation** (`expr AND expr`, `expr OR expr`): Intuitive for joining conditions such as `[countOn() >= 2] AND [C0 == 1]`.
   * **Prefix functional notation** (`AND(a, b, ...)`, `OR(a, b, ...)`, `XOR(a, b, ...)`): Convenient for variadic evaluation over arbitrary neighbor sets without repetitive binary operators, e.g., `OR(C4, C6, C5)`.
   * Both forms are supported seamlessly within the same grammar.

3. **Bracketed Sub-expressions (`[...]` and `(...)`)**:
   * Square brackets `[...]` are designated for sub-expression grouping, creating clean visual separation between condition blocks.
   * Standard parentheses `(...)` are used for function call arguments and optional grouping.

4. **Numeric & Boolean Unification**:
   * Cell values are integers: `1` (ON) and `0` (OFF).
   * Relational expressions (`==`, `!=`, `<`, `<=`, `>`, `>=`) evaluate to `1` (true) or `0` (false).
   * Logical operators treat `0` as false and any non-zero value as true.
   * The final expression evaluates to `0` or `1`. If an arithmetic expression evaluates to $>0$, it is clamped to `1`.

5. **Case Insensitivity**:
   * Keywords and identifiers (`AND`, `and`, `countOn`, `COUNTON`, `c0`, `C0`) are case-insensitive.

---

## 2. Formal Syntax Specification (EBNF)

```ebnf
RuleStatement       ::= "cell" "=" Expression ;

Expression          ::= OrExpr ;

OrExpr              ::= XorExpr ( ( "OR" | "or" ) XorExpr )* ;

XorExpr             ::= AndExpr ( ( "XOR" | "xor" ) AndExpr )* ;

AndExpr             ::= RelExpr ( ( "AND" | "and" ) RelExpr )* ;

RelExpr             ::= UnaryExpr ( CompOp UnaryExpr )? ;

CompOp              ::= "==" | "!=" | "<=" | ">=" | "<" | ">" ;

UnaryExpr           ::= ( "NOT" | "not" ) UnaryExpr 
                      | PrimaryExpr ;

PrimaryExpr         ::= Number
                      | CellRef
                      | FunctionCall
                      | LogicFunction
                      | "[" Expression "]"
                      | "(" Expression ")" ;

CellRef             ::= "C" [0-8] ;

FunctionCall        ::= "countOn()"
                      | "countOff()"
                      | "random()" ;

LogicFunction       ::= ( "AND" | "OR" | "XOR" ) "(" ArgumentList ")"
                      | ( "NOT" ) "(" Expression ")" ;

ArgumentList        ::= Expression ( "," Expression )* ;

Number              ::= [0-9]+ ;
```

---

## 3. Operator Precedence & Associativity

When evaluating an expression without explicit brackets, the following precedence table applies (from highest to lowest):

| Level | Operator / Element | Description | Associativity | Example |
| :--- | :--- | :--- | :--- | :--- |
| **1 (Highest)** | `[...]`, `(...)` | Grouped sub-expression | N/A | `[countOn() >= 2]` |
| **2** | Cells & Functions | `C0`–`C8`, `countOn()`, `random()`, `AND(...)` | N/A | `C0`, `C4`, `countOn()` |
| **3** | `NOT` | Logical Negation (unary prefix) | Right-to-left | `NOT C1`, `Not(C1)` |
| **4** | `==`, `!=`, `<`, `<=`, `>`, `>=` | Relational / Comparison | Left-to-right | `countOn() >= 3` |
| **5** | `AND` | Logical Conjunction (infix) | Left-to-right | `a AND b` |
| **6** | `XOR` | Logical Exclusive Disjunction (infix) | Left-to-right | `a XOR b` |
| **7 (Lowest)** | `OR` | Logical Disjunction (infix) | Left-to-right | `a OR b` |

---

## 4. Built-in Identifiers & Functions Reference

### 4.1 Cell References (Shorthand)

| Identifier | Returns | Relative Coordinate Offset | Description |
| :--- | :--- | :--- | :--- |
| `C0` | `0` or `1` | `(x, y)` | Current state of the cell being evaluated |
| `C1` | `0` or `1` | `(x-1, y-1)` | North-West neighbor |
| `C2` | `0` or `1` | `(x, y-1)` | North neighbor |
| `C3` | `0` or `1` | `(x+1, y-1)` | North-East neighbor |
| `C4` | `0` or `1` | `(x-1, y)` | West neighbor |
| `C5` | `0` or `1` | `(x+1, y)` | East neighbor |
| `C6` | `0` or `1` | `(x-1, y+1)` | South-West neighbor |
| `C7` | `0` or `1` | `(x, y+1)` | South neighbor |
| `C8` | `0` or `1` | `(x+1, y+1)` | South-East neighbor |

### 4.2 Aggregation & Utility Functions

| Function | Returns | Description |
| :--- | :--- | :--- |
| `countOn()` | `0` .. `8` | Count of neighbors (`C1` through `C8`) currently in state `1` (ON). Equivalent to $\sum_{i=1}^{8} Ci$. Excludes `C0`. |
| `countOff()` | `0` .. `8` | Count of neighbors (`C1` through `C8`) currently in state `0` (OFF). Equivalent to $8 - \text{countOn}()$. Excludes `C0`. |
| `random()` | `0` or `1` | Uniform random boolean output with 50% probability ($P(1) = 0.5$). |

### 4.3 Logic Functions (Variadic Prefix Form)

| Function | Signature | Semantics |
| :--- | :--- | :--- |
| `AND(...)` | `AND(expr1, expr2, ...)` | Returns `1` if all arguments evaluate to $> 0$; otherwise `0`. |
| `OR(...)` | `OR(expr1, expr2, ...)` | Returns `1` if at least one argument evaluates to $> 0$; otherwise `0`. |
| `XOR(...)` | `XOR(expr1, expr2, ...)` | Returns `1` if an odd number of arguments evaluate to $> 0$; otherwise `0`. |
| `NOT(...)` | `NOT(expr)` | Returns `1` if `expr == 0`; returns `0` if `expr > 0`. |

---

## 5. Examples & Common Automata Rules

### 5.1 Basic Examples

* **Direct cell value lookup with OR**:
  ```text
  cell = countOn() OR C5
  ```
* **Nested functional grouping with sub-expression brackets**:
  ```text
  cell = [OR(C4, C6, C5)] AND [AND(C7)]
  ```
* **Negation**:
  ```text
  cell = Not(C1)
  ```
* **Combining cell state with stochastic randomness**:
  ```text
  cell = AND(C1, random())
  ```
* **Threshold count comparisons**:
  ```text
  cell = countOn() >= 3
  cell = countOff() == 2
  ```
* **Compound rule with bracketed logic**:
  ```text
  cell = [countOn() >= 2] AND [And(C4, C8)]
  ```

---

### 5.2 Standard Cellular Automata Rule Implementations

#### 1. Conway's Game of Life (B3/S23)
* **Rule**:
  * Birth: A dead cell with exactly 3 live neighbors becomes alive.
  * Survival: A live cell with 2 or 3 live neighbors remains alive.
* **Expression (Infix Form)**:
  ```text
  cell = [countOn() == 3] OR [C0 == 1 AND countOn() == 2]
  ```
* **Expression (Prefix Functional Form)**:
  ```text
  cell = OR(countOn() == 3, AND(C0 == 1, countOn() == 2))
  ```

#### 2. HighLife (B36/S23)
* **Rule**: Similar to Conway's Life, with an extra birth condition at 6 neighbors.
* **Expression**:
  ```text
  cell = [countOn() == 3] OR [countOn() == 6] OR [C0 == 1 AND countOn() == 2]
  ```

#### 3. Seeds (B2/S)
* **Rule**: All live cells die every generation; a dead cell becomes alive if it has exactly 2 neighbors.
* **Expression**:
  ```text
  cell = [C0 == 0] AND [countOn() == 2]
  ```

#### 4. Day & Night (B3678/S34678)
* **Rule**: Symmetric under ON/OFF inversion.
* **Expression**:
  ```text
  cell = [C0 == 0 AND [countOn() == 3 OR countOn() >= 6]] OR [C0 == 1 AND [countOn() >= 3 AND countOn() != 5]]
  ```

#### 5. Brian's Brain (Excited State)
* **Expression**:
  ```text
  cell = [C0 == 0] AND [countOn() == 2]
  ```

#### 6. Majority Vote Rule
* **Rule**: The cell takes the state of the majority of its 8 neighbors.
* **Expression**:
  ```text
  cell = countOn() >= 5
  ```

---

### 5.3 Directional, Physical & Wolfram Rules

#### 1. Falling Sand / Gravity Simulation
* **Rule**:
  * Sand falls into the cell from above (`C2 == 1`) if the current cell is empty (`C0 == 0`).
  * Sand stays in the cell if it cannot fall down (`C7 == 1`).
* **Expression**:
  ```text
  cell = [C2 == 1 AND C0 == 0] OR [C0 == 1 AND C7 == 1]
  ```

#### 2. Left-to-Right Signal Propagation (Shift Register / Wire)
* **Rule**: Cell turns on if its West neighbor was on.
* **Expression**:
  ```text
  cell = C4 == 1
  ```

#### 3. Wolfram Elementary 1D Rule 30 (Using Top Row Neighbors: C1, C2, C3)
* **Rule**: $C_{next} = C1 \oplus (C2 \lor C3)$
* **Expression**:
  ```text
  cell = C1 XOR [C2 OR C3]
  ```

#### 4. Wolfram Elementary 1D Rule 110
* **Rule**: $C_{next} = (C2 \land \neg C1) \lor (C2 \oplus C3)$
* **Expression**:
  ```text
  cell = [C2 AND NOT(C1)] OR [C2 XOR C3]
  ```

#### 5. Stochastic Decay / Thermal Noise
* **Rule**: A live cell survives unless it spontaneously decays with a 50% chance when isolated (`countOn() == 0`).
* **Expression**:
  ```text
  cell = [C0 == 1 AND countOn() > 0] OR [C0 == 1 AND random()]
  ```

---

## 6. Implementation Notes for the Evaluator / Parser

1. **Tokenization**:
   * Scan whitespace and discard.
   * Recognize single/double-character symbols: `==`, `!=`, `<=`, `>=`, `<`, `>`, `=`, `[`, `]`, `(`, `)`, `,`.
   * Recognize cell identifiers `C0` through `C8` directly as cell variable tokens.
   * Recognize keywords case-insensitively (`AND`, `OR`, `XOR`, `NOT`, `countOn`, `countOff`, `random`, `cell`).
   * Recognize integer digit strings `[0-9]+`.

2. **Parsing Architecture**:
   * A standard **Recursive Descent Parser** or **Pratt Parser** maps directly to the grammar in Section 2.
   * Cell references `C0`–`C8` are parsed as variable leaf nodes reading directly from the neighborhood buffer.
