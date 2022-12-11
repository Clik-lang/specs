Point :: struct {x: i32, y: i32}

// Create a background task by declaring it in the global scope
task {
  // Do something in the background
  // Start on program launch

  // TODO: how to stop it from preventing the program from exiting?
}

shared_variable :: () {
  // Shared variable declared with `~`
  counter :~ 0;

  constant: i32 : 1;
  variable: i32 = 1;
  task {
    counter = constant;
    // counter = variable; // Error: variable is mutable and not shared
  }
  assert counter == constant;
}

nested_tasks :: () {
  counter :~ 0;
  counter = 1;
  task {
    for 0..10 {
      task {
        // `counter` is copied into the task, taking a snapshot of its value before entering the task
        // So in this case, the value of `counter` is 1
        counter += 1; // `counter` becomes 2
      }
    }
    // Each task has incremented `counter` by 1, the current thread will merge the changes.
    // The merging phase allows tasks to be executed in parallel without worrying about data race.
    // The final value of `counter` is 11
    assert counter == 11;
    // Exit the task only when all the nested tasks have exited
  }
}

conditional_task :: () {
  value :~ 0;
  task {
    // Wait for the value to be set
    task where value 1 {
      // Do something with the value
    }
    value = 1;
  }
}
