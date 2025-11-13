# **Level 20 — Denial**

## 🎯 Goal  
Make sure the owner cannot withdraw funds using the withdraw() function.

## 💥 Vulnerability and Attack Strategy 

When the contract sends Ether to another contract using `call` without specifying the gas amount, the called contract automatically **receives 63/64 of whatever gas is left at that moment**. This means the partner (the external contract) can use its `receive()` or `fallback()` to burn all the gas it gets — for example, by running an infinite loop. After that, the main `withdraw()` function **is left with only 1/64 of the gas**, and this small amount can be not enough to finish the remaining steps.

In this level, the next step after call is `transfer` function, which needs **2300 gas**.
If the remaining gas is less than that, transfer fails, and the whole transaction reverts every time — so the owner cannot withdraw any funds.

That’s why, in the attacking contract, we put an infinite loop inside `receive()` to burn all the gas forwarded by `call`.

The part of the vulnerable code:
```solidity 
partner.call{value: amountToSend}("");
payable(owner).transfer(amountToSend);
```

## 🛠 ️Solution ( Remix IDE + Browser Console)
The following steps were executed:
```js
// 1. Check the current partner - zero address
(await contract.partner()).toString()
// 2. Deploy the Denial.sol contract and call its becomePartner() function
// (Full attack logic is in Denial.sol)
// 3. Recheck the partner — Denial.sol address
(await contract.partner()).toString()
// 4. Call the attack() function - withdraw() transaction should revert because of infinite loop 
```

## 🧙 Outcome
The level was completed quickly and successfully. The transaction that calls `withdraw()` will always revert, because the `call()` inside it burns all the gas every time due to the partner contract having a “greedy” `receive()` function.
