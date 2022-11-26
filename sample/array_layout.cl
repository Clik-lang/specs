Point :: struct {
      x: i32,
      y: i32
}

LAYOUT_X: layout : Point|x|; // Layout for Point with only the x field
LAYOUT_X: |Point| : Point|y|; // Layout for Point with only the y field
LAYOUT_SOA :: Point|x.., y..|; // SOA layout for Point, with all the Xs first, then all the Ys
LAYOUT_AOSOA :: Point|x+++, y+++|; // AoSoA layout where components are grouped by 4

points: [Point] : [Point { x: 1, y: 2 }, Point { x: 3, y: 4 }];

main :: () {
  // Allocate a point array where only the `x` component matter, ultimately a `[i32]`
  points_x: [Point] : LAYOUT_X[points];
  // points_x: [Point] : |x| [Point { x: 1, y: 2 }, Point { x: 3, y: 4 }];
  for x in points_x -> print(x); // Prints 1, 3
  // for y in points_x <- compile error, y is not defined

  points_y := |y|[points];
  layout_array: ptr : |x| [Point { x: 5, y: 2 }, Point { x: 3, y: 4 }]; // The array can be directly allocated according to a layout
  // layout_array: ptr : |x| struct_array; // This is equivalent to the previous line
}