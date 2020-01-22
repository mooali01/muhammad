// 1)
//   . name  getAddress
//   . inputs/parameter:  no input
//   . adress object i.e. street, zipecode, citiy, state
//   . print/console address object
//   . no return
​
function getAddress() {
  let address = {
    street: "Lee Trevino",
    zipecode: 78664,
    city: "Eound Rock",
    state: "Texas"
  };
​
  let fullAddress = address;
​
  console.log(fullAddress);
}
​
getAddress();
​
// 2)
//   . name  getPlayers
//   . inputs/parameter:  no input
//   . players list should have at least 4 players
//   . print/console players list
//   . return players list
​
function getPlayers() {
  let list = ["Fazal Mahmood", "Mohammad Asif", "Imran Khan(The King)", "Sarfraz Nawaz"];
  return list;
}
console.log(getPlayers());
​