# **Level 19 — Alien Codex**

## 🎯 Goal  
To claim ownership of the contract.

## ✅ TL ;DR

Underflow `codex.length` → compute i such that `keccak256(p) + i ≡ 0 (mod 2^256)` → call `revise(i, bytes32(myAddress))` → overwrite `storage[0]` and become owner.

## 💥 Vulnerability
In Solidity versions before 0.8 there are no automatic checks for underflow/overflow, so this contract exploits that vulnerability.

The part of the vulnerable code:
```solidity 
function retract() public contacted {
        codex.length--;
    }
```

## 👉 Theoretical background and Attack Idea
Unlike other programming languages such as Python or JavaScript, Solidity allows changing the length of an array, because it’s not a high-level language with a safe runtime environment. When I call `arr.length` and try to modify it — I can, since under the hood it’s just a direct write to a storage slot. Therefore, `arr.length` is not a **read-only property** like in the most languages, but simply a storage slot that I have full access to. It’s my responsibility as a developer to handle any array resizing carefully — both increasing and decreasing its length.

The Solidity compiler, before writing a value into a dynamic array at a specific index `arr[i] = elem`, always performs a check: `require(i < arr.length);`. That means to write into a certain storage slot - the array length must be large enough.

Solidity calculates where array elements are stored using the formula:
`keccak256(length_slot) + i`, where length_slot is the storage slot that holds the array length.

To become the contract owner (the _owner variable inherited from the **Ownable contract**), it’s necessary to overwrite data in storage slot 0, because that’s where variable _owner is stored.

Each contract has 2^256 storage slots, each of 32 bytes, because the **EVM is a 32-byte architecture**.
If the calculated slot index exceeds **max(uint256)** (that is, index >= 2^256), the addressing wraps around — all writes occur within the range [0, 2**256 - 1]. So we need to find such an index i that satisfies the equation: `(keccak256(length_slot) + i) mod 2^256 = 0`. A write to this index will be equivalent to writing to storage slot 0, because of the circular addressing.

Let’s expand the equation:
`keccak256(length_slot) + i = k * 2^256`, where k is a positive integer.
Taking k = 1, we get
`i = 2^256 - keccak256(length_slot)`
or, in Solidity code:
```solidity 
uint256 index = type(uint256).max + 1 - uint256(keccak256(abi.encode(length_slot)));
```
#### Storage layout — General principles

- **Packing**: Solidity tries to save space: small state variables declared consecutively are packed into a single 32-byte storage slot when they fit (total ≤ 32 bytes).

- **Static vs dynamic types**: Static types (uint, bool, address, bytes1..bytes32, etc.) store their values directly in their slot. Dynamic types (string, bytes, dynamic array, mapping) store a length/pointer/placeholder in their slot, while the actual data is kept elsewhere: array/string data lives at `keccak256(abi.encode(slot)) + index`, and mapping entries at `keccak256(abi.encode(key, slot))`.

- **Inheritance / linearized layout**: When a contract inherits from other contracts, storage is merged into a `single contiguous space`: parent contract variables (in linearized order) occupy the first slots, then the child’s variables follow. Private variables still occupy their storage slots — they are only inaccessible by name from derived contracts, but the slots themselves exist and can be read at the low level. 


## 🛠 ️Solution ( Remix IDE + Browser Console)
The following steps were executed:
1.  First, I work in the console and check what the initial memory slots of this contract contain.
```js
// 0. Introduce the addr variable - temporary contract instance 
let addr = "0x5C508b322301702133A788e1aebffbf83465050F";
// 1. Check the 1st (0 index) of storage slot --> it contains boolean contact + owner address 
// '0x0000000000000000000000000bc04aa6aac163a6b3667636d798fa053d43bd11'
await web3.eth.getStorageAt(addr, '0x0');
// 2. Check the 2st (1 index) of storage slot --> it contains codex length 
//'0x0000000000000000000000000000000000000000000000000000000000000000'
await web3.eth.getStorageAt(addr, '0x1');
// 3. Check the contact variable --> false, not contacted yet 
await contract.contact()
```

As a result of checking the memory slots, I am convinced that the length of dynamic array codex is in the slot with index 1. I will use this index further.

2. Secondly, I wrote a micro contract where I implemented the function of calculating the `index`, where I will save my personal address in order to become the owner.

3. Thirdly, I wrote an attack contract AlienCodex.sol and successively called 3 of its functions through Remix (public functions):  
- **makeContact()** - to set contact (so that contact = true)
- **retract()** - to decrease the length by one, this will just cause an underflow, the length will turn from zero into the maximum number of the uint256 type, that is, into `2^256 - 1`
- **revise (index, newOwner)** - I write my address into the 0 slot of the contract's memory, intercepting ownership.

## 🧙 Outcome
The exploit succeeded — by underflowing codex.length and calculating an index i such that keccak256(p)+i ≡ 0 (mod 2^256), I overwrote storage[0] and replaced _owner with my address.
