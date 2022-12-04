Player :: struct {
    name: string,
    score: i32,
}

players :: table {
  using player: Player,
}

append_player :: () {
  insert players {
    name: "John",
    score: 10,
  }
}

handle_scores :: () {
  result :: select |score| players;

  merge: i32 = 0;
  for .score in result -> merge += score;

  // Increment the score of all players
  update players -> .score += 1;
}