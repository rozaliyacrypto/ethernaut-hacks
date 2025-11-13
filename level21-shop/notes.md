# **Level 21 — Shop**

## 🎯 Goal  
As a Buyer contract, I need to get the item from the Shop contract for a price lower than it asks for.

## 💥 Vulnerability and Attack Strategy 
The vulnerability is that the `price()` function of the **Buyer** is called twice, and even though it’s a view function, it can still return different values. This happens because inside `price()` we can call another view function whose value changes between the two calls due to external factors.

In this level, the variable `isSold` changes from false to true between the two `_buyer.price() calls`. We can use this to our advantage: `price()` returns one number on the first call, and a different number on the second. 

The part of the vulnerable code:
```solidity 
if (_buyer.price() >= price && !isSold) {
      isSold = true;
      price = _buyer.price();
    }
```

## 🛠 ️Solution ( Remix IDE + Browser Console)
The following steps were executed:
```js
// 1. Check the current price - 100
(await contract.price()).toString()
// 2. Check the variable isSold - false
(await contract.isSold()).toString()
// 3. Deploy the Shop.sol contract and call its attack() function
// (Full attack logic is in Shop.sol)
// 4. Recheck the price — 0
(await contract.price()).toString()
// 5. Recheck the variable isSold - true
(await contract.isSold()).toString()
```

## 🧙 Outcome
The contract was hacked quickly and successfully. Remember that a **view function cannot modify storage, emit events, or call external functions that are not view/pure**. It can only read storage/memory/calldata and call other view/pure functions.
