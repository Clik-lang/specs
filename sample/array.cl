Point :: struct {
      x: i32,
      y: i32
}

// Array declaration
// `[T]` is a language shortcut for `Array<T>`, which is a standard language class
// The `Array` class represents a fixed-size array of elements typed `T`
// TODO: should array be responsible for storing the layout?
points: [Point] : [Point { x: 1, y: 2 }, Point { x: 3, y: 4 }];

array :: () {
  function_getter :: points.get(0); // `Array#get(usize)`
  operator_getter :: points(0); // Operator overloading `operator(index: usize) -> T`

  points.set(0, Point { x: 5, y: 6 }); // `Array#set(usize, T)`
}

get_points :: () [Point] {
  // `#return_layout` retrieves the array layout at the call site return
  // e.g. `_ :: |x| get_points()`
  // The compiler may automatically infer the layout (assuming no pointer operations)
  return |#return_layout| [Point { x: 1, y: 2 }, Point { x: 3, y: 4 }];
}

layout :: () {
  // Direct layout declaration must specify the target type
  // Syntax: `<type>|<layout>|`
  LAYOUT_X: |Point| : Point|x|; // Layout for Point with only the x field
  LAYOUT_X :: Point|y|; // Layout for Point with only the y field
  LAYOUT_SOA :: Point|x.., y..|; // SOA layout for Point, with all the Xs first, then all the Ys
  LAYOUT_AOSOA :: Point|x+++, y+++|; // AoSoA layout where components are grouped by 4

  // Allocate a point array where only the `x` component matter, ultimately a `[i32]`
  // The type remains `Point` but the layout is changed, and unspecified components are innaccessible
  points_x: [Point] : |LAYOUT_X| get_points();
  for x in points_x -> print(x); // Prints 1, 3
  // The `y` component is unused, and thus innaccessible
  // for y in points_x <- compile error, y is not defined

  points_y :: |y| get_points();
  for y in points_y -> print(y); // Prints 2, 4
}

layout_pointer :: () {
  // Although arrays with custom layout can be used as normal, the backed memory does reflect the change.
  points_x: [Point] : |x| [Point { x: 1, y: 0 }, Point { x: 2, y: 0 }, Point { x: 3, y: 0 }];
  assert points_x.length() == 3;
  // Get a pointer pointing to a continuous block of Point's `x` components [1, 2, 3]
  pointer : ptr : points_x.as_ptr(); // Get a pointer to the array

  x_1 :: pointer.load<i32>(0);
  x_2 :: pointer.load<i32>(1);
  x_3 :: pointer.load<i32>(2);

  assert x_1 == 1;
  assert x_2 == 2;
  assert x_3 == 3;
}
