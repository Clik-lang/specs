class List<T> {
  ::new();
  push(element: T);
  pop() T;
  get(index: size_t) T;
  set(index: size_t, element: T);
  length() size_t;
}

spe List<T> {
  // TODO: specialization
}


test "list" {
  list :: List<i32>::new();
  assert list.length() == 0;

  list.push(1);
  assert list.length() == 1;
  assert list.get(0) == 1;

  list.set(0, 2);
  assert list.get(0) == 2;
  assert list.pop() == 2;
  assert list.length() == 0;
}