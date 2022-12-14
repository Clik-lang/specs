
{
  //////////////////////////
  // Function declaration //
  //////////////////////////

  // Function taking two `i32` parameters and returning another `i32`.
  add_1 :: (a: i32, b: i32) i32 {
    return a + b
  }

  // `return` can be omitted
  add_2 :: (a: i32, b: i32) i32 {
    a + b
  }

  // Brackets can be replaced by an arrow `->` and a single return expression
  add_3 :: (a: i32, b: i32) i32 -> a + b;

  // Square brackets can be defined before any block to declare captures
  // It is optional, but can be useful during refactoring and avoid mistakes (e.g. multi-threading)
  add_4 :: (a: i32, b: i32) i32 [&add_1] {
    return add_1(a, b)
  }

  tuple :: () (i32, i32) {
    return 1, 2;
  }

  tuple_2 :: () (i32, i32) -> 1, 2;

  // Function can take other function pointers as parameters
  callback :: (fn: (i32, i32) i32) i32 -> fn(1, 2);

  // `where` clause can be used to define constraints on type parameters
  constraints :: (a: i32) i32 where .a > 0 {
    return a
  }
}

{
  //////////////////////////
  // Variable declaration //
  //////////////////////////

  // `::` defines a constant with implicit type
  const_num :: 5;
  const_num_typed: i32 : 5; // Typed version

  // Function requiring a constant parameter
  constant_function :: (constant::i32) i32 -> constant;

  // `:=` is the mutable version
  num := 5;
  num = 6;
  num_typed: i32 = 5; // Typed version
}

///////////////
// Ownership //
///////////////
{
  Point :: struct {x:i32, y:i32}
  point :: Point {1, 2};
  // Borrowing a reference to a struct
  function :: (p: &Point) -> i32 {
    p.x + p.y
  }

  value :: function(&point);

  point2 :: point;
  // point.x = 3; // Error: cannot assign to immutable field
}

// Main function
main :: () {
  // Local function
  {
    add :: (a: i32, b: i32) i32 -> a + b;
    num :: add(1, 2);

    tuple :: () (i32, i32) -> 1, 2;
    result: (i32, i32) = tuple();
    assert result.0 == 1;
    assert result.1 == 2;
  }

  ///////////////
  // Structure //
  ///////////////
  {
    Point :: struct {
      x: i32,
      y: i32
    }

    point :: Point {.x: 1, .y: 2};
    assert point.x == 1;
    assert point.y == 2;

    array :: [1, 2];
    assert array[0] == 1;
    assert array[1] == 2;

    struct_array: []Point : {{.x: 1, .y: 2}, {.x: 3, .y: 4}};
    // Equivalent to:
    struct_array_2: []Point : {Point {.x: 1, .y: 2}, Point {.x: 3, .y: 4}};

    Tuple :: struct {
      coord: (x: i32, y: i32),
    }
    unamed :: Unamed {.coord: (1, 2)};
    coord: (i32, i32) = unamed.coord;
    assert coord.0 == 1;
    assert coord.1 == 2;
    assert coord.x == 1;
    assert coord.y == 2;
  }

  ///////////
  // Union //
  ///////////
  {
    Value :: union {
      number: i32,
      point: struct {x: i32, y: i32},
    }
    v_num :: Value {.number: 1};
    v_point :: Value {.point: Point {.x: 1, .y: 2}};
    // Verify an union value type
    // TODO
  }

  {
    defer println("Deferred");
  } // End of the scope, should print

  //////////////////
  // Control flow //
  //////////////////
  {
    number :: 5;
    // Syntax: `if <condition> <block> [else <statement>]`
    if number == 5 -> print("Branch taken!");
    if number == 5 {
      print("Branch taken!");
    } else if number == 6 {
      print("Branch not taken!");
    }

    // If blocks take an optional primary expression, and a list of potential branches to be taken.
    // Execution does not stop after a branch is taken.
    // Syntax: `if [<condition_part>] (<condition> <block>)...
    if {
      number == 5 -> print("Branch taken!");
      number >= 5 -> print("Branch taken!");
      number == 6 -> print("Invalid!");
      else -> print("AlsoInvalid!");
    }

    if number {
      == 5 -> print("Branch taken!");
      >= 5 -> print("Branch taken!");
      == 6 -> print("Invalid!");
      else -> print("AlsoInvalid!");
    }

    // Match blocks are the same as if's, except that only the first successful branch is taken.
    match number {
      == 5 -> print("Branch taken!");
      >= 5 -> print("Invalid!");
      == 6 -> print("Invalid!");
      else -> print("Invalid!");
    }

    // Looping
    points :: []Point{{ x: 1, y: 2 }, { x: 3, y: 4 }};
    // Iterate over a struct array
    for point: points -> print(point.x);
    // Iterate over a struct's components
    for .x: points -> print(x);
    for (.x, .y): points -> print(x, y);

    // Iterate over a range
    for i: 0..10 -> print(i);
    // Iterate over a range with a step
    for i: 0..10..2 -> print(i);
    // Iterate over a range with a step and a condition
    for i: 0..10..2 < 5 -> print(i);
    // Same but without the index
    for 0..10 -> print("Looping!");
    for 0..10..2 -> print("Looping!");
    for 0..10..2 < 5 -> print("Looping!");
    // Infinite loop
    for -> print("Looping!");

    // "while" loops
    {
      count := 0;
      for count < 5 -> count = count + 1;
    }
  }

  //////////////////////////////
  // Raw address manipulation //
  //////////////////////////////

  // Data can be extracted from raw addresses using the `ptr` type
  // The `alloca` intrinsic is used to allocate memory on the stack
  // Syntax: `alloca <type> [<count>] [align <alignment>]`
  address: ptr : alloca i32 2, align 4;
  {
    address.store<i32>(0, 5);
    address.store<i32>(1, 10);
    first :: address.load<i32>(0);
    second :: address.load<f32>(1); // Any type can be loaded, as long as it fits the size of the address
  }

  ///////////////////
  // Memory layout //
  ///////////////////

  // Layout can be defined for array expressions in order to precise how elements should be laid out in memory
  // This can for example be used to declare an array as SOA (Structure of Arrays) instead of AOS (Array of Structures)
  // without needing third party libraries support.
  // The layout syntax is defined by rules surrounded by vertical bars `|<rules>|`.
  // Layouts are reflected in the type: `[<type>]` becomes `[<type>{<component_1>, <component_2>, ...}]`.

  // |x| -> retrieve the `x` component
  // |y| -> retrieve the `y` component
  // |(x, y)| -> AoS layout with `x` and `y` components
  // |x.., y..| -> SoA layout with `x` and `y` components
  // |(x+++, y+++)| -> AoSoA layout where components are grouped by 4
  // |(x, y)~| -> AoS layout with each element aligned to the cache line size
  // |(x+++, y+++)~| -> AoSoA layout cache line aligned

  points: []Point : {{.x: 1, .y: 2}, {.x: 3, .y: 4}};
  points_xy: []Point{x, y} : |(x, y)| points; // Essentially the same, but more strictly typed
  points_x: []Point{x} : |x| points_xy; // Remove the `y` component
  for .x: points_x -> print(x); // Prints 1, 3
  // for .y: points_x <- compile error, `y` is not defined

  // Although arrays with custom layout can be used as normal, the backed memory does reflect the change.
  // Get a pointer pointing to a continuous block of Point's `x` components [1, 2]
  pointer : ptr : points_x.as_ptr(); // Get a pointer to the array
  assert pointer.load<i32>(0) == 1;
  assert pointer.load<i32>(1) == 2;
}

////////////
// Macros //
////////////

// Macros are explicit compiler intrinsics increasing the language flexibility
{
  line: i32 : #line; // Current line number
  number: i32 : #insert { "5" }; // Insert code as string
  number_2: i32 : #insert -> "5" ;
  size: usize : #size(i32); // Get the size of any type in bytes
  is_constant: bool : #is_constant(5); // Check if an expression is a compile-time constant
  is_escaping: bool : #is_escaping(number); // Check if an expression is escaping, can be used to decide between stack and heap allocation
  // #panic("Error message"); // Panic with an error message
}
