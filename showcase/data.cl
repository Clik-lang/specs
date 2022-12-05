// Basics
// i8, u8, i16, u16, i32, u32, i64, u64, f32, f64, bool

// STRUCTURES
{
  Point :: struct {
    x: i32,
    y: i32,
  }
  Point_2 :: struct {
    coord: struct {x: i32, y: i32}
  }
}

// ENUMS
// Enums are a special type of data structure that can be used to
// represent a fixed set of values.
{
  Direction :: enum {
    North,
    South,
    East,
    West
  }
  // They can also hold immutable data.
  // Syntax: `enum [<type>] {<name> [:: <expression>], ...}`
  Component :: enum Point {
    Position :: {x: 1, y: 2},
    Velocity :: {x: 3, y: 4},
  }
  // Open enums are similar to enums, but they can be extended externally.
  // Syntax: `open enum [<type>];`
  ComponentOpen :: open enum Point;
  // Type extensions are used to extend open types.
  // Syntax: `extend <type> {<name> [:: <expression>], ...}`
  extend ComponentOpen {
    Position :: {x: 1, y: 2},
    Velocity :: {x: 3, y: 4},
  }
}

// UNIONS
// Unions are similar to enums, but each instance can hold different data.
// Syntax: `union {<name> [:: <type>], ...}`
{
  Component :: union {
    Position :: struct {x: i32, y: i32},
    Velocity :: struct {x: i32, y: i32},
  }
  // Open unions
  ComponentOpen :: open union;
  extend ComponentOpen {
    Position :: struct {x: i32, y: i32},
    Velocity :: struct {x: i32, y: i32},
  }
}


// FLAGS
// Flags are true/false values that can be combined.
{
  // Syntax: `flags {<name>, ...}`
  Flags :: flags {
    A,
    B,
    C,
  }
  // Open flags
  FlagsOpen :: open flags;
  extend FlagsOpen {
    A,
    B,
    C,
  }
}
