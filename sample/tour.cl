
{
  /////////////////////////////
  // 1. Function declaration //
  /////////////////////////////

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

  // Function can take other function pointers as parameters
  callback :: (fn: (i32, i32) i32) i32 -> fn(1, 2);
}

{
  /////////////////////////////
  // 2. Variable declaration //
  /////////////////////////////

  // `::` defines a constant with implicit type
  const_num :: 5;
  const_num_typed: i32 : 5; // Typed version

  // `:=` is the mutable version
  num := 5;
  num = 6;
  num_typed: i32 = 5; // Typed version
}

// Main function
main :: () {
  // Local function
  add :: (a: i32, b: i32) i32 -> a + b;
  num :: add(1, 2);

  // Struct declaration
  Point :: struct {
      x: i32,
      y: i32
  }

  // Struct instantiation
  point :: Point { x: 1, y: 2 };
  assert point.x == 1;
  assert point.y == 2;

  array :: [1, 2];
  assert array[0] == 1;
  assert array[1] == 2;

  struct_array: [Point] : [Point { x: 1, y: 2 }, Point { x: 3, y: 4 }];
  struct_array[0].x = 5;


  {
    defer println("Deferred");
  } // End of the scope, should print

  //////////////////
  // 3. Branching //
  //////////////////
  {
    number :: 5;
    // Syntax: `if <condition> <block> [else <statement>]`
    if number == 5 -> print("Branch taken!");
    if number == 5 {
      print("Branch taken!");
    }else if number == 6 {
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
  }


  /////////////////////////////////
  // 4. Raw address manipulation //
  /////////////////////////////////

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

  //////////////////////
  // 5. Memory layout //
  //////////////////////

  // Layout can be defined for array expressions in order to precise how elements should be laid out in memory
  // This can for example be used to declare an array as SOA (Structure of Arrays) instead of AOS (Array of Structures)
  // without needing third party libraries support.
  // The layout syntax is defined by rules surrounded by vertical bars `|<rules>|`.
  points: [Point] : |x| [Point { x: 1, y: 2 }, Point { x: 3, y: 4 }];
  for x in points -> print(x); // Prints 1, 3
  // for y in points_transform <- compile error, y is not defined
}

///////////////
// 6. Macros //
///////////////

// Macros are used to insert arbitrary code from compile-time string
{
  number: i32 : #insert { "5" }; // Insert code as string
  number_2: i32 : #insert -> "5" ;
  size: usize : #size(i32); // Get the size of any type in bytes
  is_constant: bool : #is_constant(5); // Check if an expression is constant
}

//////////////////////////
// 7. Class declaration //
//////////////////////////

// Classes are containers combining a structure & local functions.
// They intentionally cannot access any outer scope and are entirely independent.
// There is a clear distinction between a class API and its implementation, allowing specializers to choose the most appropriate one without side-effect.
class Object {
  // Factory function
  // Must return a new instance of the class
  ::new();
  // Local functions
  get() i32;
  set(value: i32);

  // Operator overloading
  // Must return a new instance of the class, and the parameter be of the same type
  operator+();

  // Inline implementation, used by default
  impl {
    // Class structure
    struct {
      value: i32,
    }

    // Function implementations have implicit parameters/return type as defined in the class

    ::new {
      self.value = 1;
    }

    set {
      self.value = value;
    }

    get {
      return self.value;
    }

    operator+ {
      // TODO how should be named the right-side value?
      return Object { value: self.value + object.value };
    }

    defer {
      // Called whenever the class goes out of scope
    }
  }
}

main_class :: () {
  // Class instantiation
  object :: Object::new();
  assert object.get() == 1;
  object.set(2);
  assert object.get() == 2;
}