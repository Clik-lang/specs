////////////
// Basics //
////////////

// i8, u8, i16, u16, i32, u32, i64, u64, f32, f64, bool

////////////////
// Integrated //
////////////////
{
  str: string : "Hello, World!";
  cstr: cstring : c"Hello, World!"; // Zero-terminated string.
  number: type : i32;
}

////////////////
// Structures //
////////////////
{
  Point :: struct {
    x: i32,
    y: i32,
  }

  point: Point : Point {.x: 1, .y: 2};
  point2: Point : {.x: 1, .y: 2};
  point3: Point : {1, 2};
  point4 :: Point {.x: 1, .y: 2};
  point5 :: Point {1, 2};

  // Equivalent to `Point`
  // `using` is used to place the type in the current scope.
  Alias :: struct {
    using point: Point,
  }
  alias :: Alias {point: {.x: 1, .y: 2}};
  assert alias.x == 1 && alias.y == 2;

  // Remove the `point` field.
  AliasDirect :: struct {
    using Point,
  }
  alias_direct :: Alias {.x: 1, .y: 2};
}
// Wither
{
  // On structure
  Point :: struct {x: i32, y: i32}
  point := Point {.x: 1, .y: 2};
  point = point with {.x: 3};
  // On array
  array := [1, 2, 3];
  array = array with {.0: 4};
}
//////////////
// Generics //
//////////////
{
  Point :: struct (N: type) {x: N, y: N}
  increment :: (coord: $T/Point, value: T.N) -> Point (T.N) ->
    {coord.x + value, coord.y + value}
  increment_2 :: (coord: Point($N), value: N) -> Point (N) ->
    {coord.x + value, coord.y + value}

  point := Point (i32) {.x: 1, .y: 2};
  point = increment(point, 1);
  point = increment_2(point, 1);

  Player :: struct {
    coordinates: Point (i32),
  }
  player :: Player {
    coordinates: Point (i32) {.x: 1, .y: 2},
  }
  player2 :: Player {{.x: 1, .y: 2}}
}

////////////
// Arrays //
////////////

// Arrays have the type `[<type]` and are initialized using `[<expression>, ...]`
{
  // Expressions syntax: `[<layout>] [<type>][<expression>, ...]`

  numbers: [i32] : [1, 2, 3, 4, 5];
  // Array expression type can be explicit by prefixing the brackets with the type.
  numbers_2 :: i32[1, 2, 3, 4, 5];
  // Implicit type deduction is also possible.
  numbers_3 :: [1, 2, 3, 4, 5];

  element :: numbers[0];
  numbers[0] = element + 1;

  length :: numbers.length;

  Point :: struct {x: i32, y: i32}
  // We are only interested in the `x` field.
  points_x: [Point{x}] : |x| [{.x: 1, .y: 2}, {.x: 3, .y: 4}];
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
    Position :: {.x: 1, .y: 2},
    Velocity :: {.x: 3, .y: 4},
  }
  for point: Component -> print(point);
  // Dynamic type
  Component2 :: enum {
    Position :: Point {.x: 1, .y: 2},
    Velocity :: Point {.x: 3, .y: 4},
  }
  // Open enums are similar to enums, but they can be extended externally.
  // Syntax: `open enum [<type>];`
  ComponentOpen :: open enum Point;
  // Type extensions are used to extend open types.
  // Syntax: `extend <type> {<name> [:: <expression>], ...}`
  extend ComponentOpen {
    Position :: {.x: 1, .y: 2},
    Velocity :: {.x: 3, .y: 4},
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

  Point :: struct {x: i32, y: i32}
  // Constant type
  Component2 :: union Point {
    Position, Velocity,
  }

  // Open unions
  ComponentOpen :: open union;
  extend ComponentOpen {
    Position :: struct {x: i32, y: i32},
    Velocity :: struct {x: i32, y: i32},
  }

  value: Component : Position {.x: 1, .y: 2};
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

  set: Flags : A | B;
  if set.A -> print("A");
  if set.B -> print("B");
  if set.C -> print("Invalid");

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
  set: <Component> : <Position {.x: 1, .y: 2}, Velocity {.x: 3, .y: 4}>;
  // Explicit expression type
  set_2 :: Component<Position {.x: 1, .y: 2}, Velocity {.x: 3, .y: 4}>;
  // Implicit type
  set_3 :: <Position {.x: 1, .y: 2}, Velocity {.x: 3, .y: 4}>;
  // Iteration
  for component: set -> print(component);
  // Retrieve individual elements
  position :: set<Position>;
  velocity :: set<Velocity>;

  set<Position> = {.x: 1, .y: 2};
}

////////////
// Tables //
////////////

// Tables are used to store a collection of types, and allow for queries.
{
  Entry :: struct {
    name: string,
    age: i32,
  }
  // Table type
  // Syntax: `table <type>`
  // Syntax: `table {<name> [:: <type>], ...}`
  // TODO table meta (uniqueness, triggers, constraints, etc.)
  EntryTable :: table Entry;
  EntryTable2 :: table {name: string, age: i32};

  // Initialization
  // Syntax: `<type> {[<name> [: <expression>], ...]}`
  collection :: EntryTable {};
  //collection :: EntryTable {{.name: "John", .age: 20}};

  // Insertion
  // Syntax: `insert <table> <element>`
  insert collection {.name: "John", .age: 20};

  // Query
  // Syntax: `select <table> [<layout>] [where <name> <predicate>, ...]`
  result: [Entry] : select collection where .age > 18;
  //result: [i32] : select collection |age| where .age > 18 {age};
  //result :: select collection {age: >18};

  // Delete
  // Syntax: `delete <table> [<layout>] [where <name> <predicate>, ...]`
  delete collection where .age > 18;
}
// Inner table
{
  Slot :: enum {
    WEAPON, SHIELD,
    HELMET, CHEST,
    LEGS, BOOTS
  }
  Inventory :: table {
    slot: Slot,
    rarity: i32,
  }
  Player :: struct {
    name: string,
    age: i32,
    inventory: Inventory,
  }
  player :: Player {
    .name: "John",
    .age: 20,
    .inventory: {
      {WEAPON, 1},
      {SHIELD, 1},
    }
  }

  // Anonymous type `Inventory{}`
  weapon :: select_first player.inventory where .slot == WEAPON;
  slot :: weapon.slot;
  rarity :: weapon.rarity;
}
// Table constraints
{
  IdTable :: table {
    id: i32: unique
  } where .id > 0;
  collection :: IdTable {};
  insert collection {.x: 1};
  //insert collection {.x: 0}; -> Panic

  // Default value
  IdTableDefault :: table {
    id: i32: unique,
    name: string: default "John",
  } where .id > 0;
  collection_default :: IdTableDefault {};
  insert collection_default {.id: 1};
  result :: select_first collection_default where .id == 1;
  assert result.name == "John";
}
// Open table
{
  TableOpen :: open table;
  extend TableOpen {
    name: string,
    age: i32,
  }
  collection :: TableOpen {};
  insert collection {.name: "John", .age: 20};

  extend TableOpen {
    height: i32, // No default value, zero-initialized
  }
  result :: select_first collection where .name == "John";
  assert result.height == 0; // Zero-initialized
}
