function getAccountBalance(accountBalance, billAmmount) {
  if (billAmmount <= 0) {
    console.log("Congrat , You have nothing due !");
    return;
  }
  if (accountBalance <= 0) {
    console.log("You do not have balance to pay bill.");
    return;
  } else if (accountBalance < billAmmount) {
    console.log("You have insufficient balance to pay bill.");
    return;
  } else {
    console.log("Your's bill is being proceessed!");
    return;
  }
}

getAccountBalance(100, 0);
getAccountBalance(100, 110);
getAccountBalance(0, 110);

// for first call-- > Congrat, You have nothing due!
// for second call. -- > You have insufficient balance to pay bill.
// for this call. -- > rYou do not have balance to pay bill. (edited)
