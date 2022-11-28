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
