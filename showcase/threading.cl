Point :: struct {x: i32, y: i32}

fork_statement :: () {
  constant: i32 : 1;
  variable: i32 = 1;
  // Shared variable declared with `~`
  counter :~ 0;
  // fork statement loop
  fork 0..10 {
    // `counter` is copied into the stack, taking a snapshot of its value before entering the task
    // So in this case, the value of `counter` is 1
    counter += 1; // `counter` becomes 2
  } // `counter` exits the task, the value is merged back into the main thread
  // Each fork has incremented `counter` by 1, the current thread will merge the changes.
  // The merging phase allows tasks to be executed in parallel without worrying about data race.
  // The final value of `counter` is 11
  // Blocks until all the nested forks have exited
  assert counter == 11;

  // Infinite fork
  fork {
    break;
  }
}

fork_expression :: () {
  // `fork` expression
  // The expression is evaluated in parallel
  // The result is a merge of all the results
  result :: fork 0..10 -> 1;
  assert result == 10

  result_map :: fork i: 0..2 -> map[i32]i32 {i: i + 5};
  assert result_map == map[i32]i32 {0: 5, 1: 6};

  //result_map2 :: fork -> 1; // Error: infinite fork
}

spawn_basics :: () {
  // `spawn` creates a new task running in the background
  // The task is not joined, so the main thread may not wait for it to finish
  for i: 0..10 -> spawn -> print("Hello: ", i);

  // Async tasks can access both shared & local variables using the ownership system
  shared :~ 0;
  variable := 0;
  spawn { // TODO: maybe enforce capture syntax `[<name>, ...]`?
    shared = 2;
    variable = 2;
  }
  // `shared` & `variable` are moved into the task, so it cannot be accessed anymore
  // variable = 2; // Error: variable is not accessible
}

// Create a background task by declaring it in the global scope
started :~ false;
// Iteration starts when `started` is set to true or when the timeout is reached
// The `where` keyword makes the loop wait for the condition to be true
fork where started true || #timeout 1000 {
  break;
}

////////////////
// Web server //
////////////////
{
  start_server :: () {
    for {
      connection :: accept();
      spawn {
        request :: read(connection);
        write(connection, 5);
      }
    }
  }
  accept :: () i32 -> 0;
  read :: (connection: i32) i32 -> 1;
  write :: (connection: i32, value: i32) -> {
    // Do something
  }
}
