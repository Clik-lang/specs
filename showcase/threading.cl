Point :: struct {x: i32, y: i32}

shared_variable :: () {
  // Shared variable declared with `~`
  counter :~ 0;

  constant: i32 : 1;
  variable: i32 = 1;
  fork {
    counter = constant;
    // counter = variable; // Error: variable is mutable and not shared
    break; // Exit the task
  }
  assert counter == constant;
}

counting_fork :: () {
  counter :~ 0;
  counter = 1;
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
}

counting_spawn :: () {
  // `spawn` creates a new task running in the background
  // The task is not joined, so the main thread may not wait for it to finish
  for i: 0..10 -> spawn -> print("Hello: ", i);

  // Async tasks cannot access shared variables
  shared :~ 0;
  spawn {
    // shared = 1; // Error: variable is not mutable
  }

  // Variables can be captured using the ownership system
  variable := 0;
  variable = 1;
  spawn { // TODO: maybe enforce capture syntax `[<name>, ...]`?
    variable = 2;
  }
  // `variable` is moved into the task, so it cannot be accessed anymore
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
