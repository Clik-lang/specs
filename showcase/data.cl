////////////
// Basics //
////////////
// i8, u8, i16, u16, i32, u32, i64, u64, f32, f64, bool

////////////////
// Integrated //
////////////////
// string

////////////////
// Structures //
////////////////
{
  Point :: struct {
    x: i32,
    y: i32,
  }
}

////////////
// Arrays //
////////////
// Arrays have the type `[<type]` and are initialized using `[<expression>, ...]`
{
  numbers: [i32] : [1, 2, 3, 4, 5];
  // Array expression type can be explicit by prefixing the brackets with the type.
  numbers_2 :: i32[1, 2, 3, 4, 5];
  // Implicit type deduction is also possible.
  numbers_3 :: [1, 2, 3, 4, 5];

  element :: numbers[0];
  numbers[0] = element + 1;
}

///////////
// Enums //
///////////
// Enums are a special type of data structure that can be used to
// represent a fixed set of values.
{
  Direction :: enum {
    North,
    South,
    East,
    West
  }
  Point :: struct {x: i32, y: i32}
  // They can also hold immutable data.
  // Syntax: `enum [<type>] {<name> [:: <expression>], ...}`
  // Constant type
  Component :: enum Point {
    Position :: {x: 1, y: 2},
    Velocity :: {x: 3, y: 4},
  }
  for point: Component -> print(point);
  // Dynamic type
  Component2 :: enum {
    Position :: Point {x: 1, y: 2},
    Velocity :: Point {x: 3, y: 4},
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

////////////
// Unions //
////////////
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

  value: Component : Position {x: 1, y: 2};
  // Find type
  if value.Position -> print("Position: ", value);
  match value {
    .Position -> print("Position: ", value);
    else -> print("Unknown");
  }
}


///////////
// Flags //
///////////
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

//////////
// Sets //
//////////
// Sets are arrays that can only contain a single element of each type (support for `union` and `enum`)
// The syntax is similar to arrays but using `<>` instead of square brackets.
{
  Component :: union {
    Position :: struct {x: i32, y: i32},
    Velocity :: struct {x: i32, y: i32},
  }

  set: <Component> : <Position {x: 1, y: 2}, Velocity {x: 3, y: 4}>;
  // Explicit expression type
  set_2 :: Component<Position {x: 1, y: 2}, Velocity {x: 3, y: 4}>;
  // Implicit type
  set_3 :: <Position {x: 1, y: 2}, Velocity {x: 3, y: 4}>;
  // Iteration
  for component: set -> print(component);
  // Retrieve individual elements
  position :: set<Position>;
  velocity :: set<Velocity>;

  set<Position> = {x: 1, y: 2};
}
