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

layout :: () {
  LAYOUT_X: layout : Point|x|; // Layout for Point with only the x field
  LAYOUT_X: |Point| : Point|y|; // Layout for Point with only the y field
  LAYOUT_SOA :: Point|x.., y..|; // SOA layout for Point, with all the Xs first, then all the Ys
  LAYOUT_AOSOA :: Point|x+++, y+++|; // AoSoA layout where components are grouped by 4

  // Allocate a point array where only the `x` component matter, ultimately a `[i32]`
  points_x: [Point] : LAYOUT_X[points];
  // points_x: [Point] : |x| [Point { x: 1, y: 2 }, Point { x: 3, y: 4 }];
  for x in points_x -> print(x); // Prints 1, 3
  // for y in points_x <- compile error, y is not defined

  points_y := |y|[points];
  layout_array: ptr : |x| [Point { x: 5, y: 2 }, Point { x: 3, y: 4 }]; // The array can be directly allocated according to a layout
  // layout_array: ptr : |x| struct_array; // This is equivalent to the previous line
}