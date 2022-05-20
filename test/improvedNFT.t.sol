// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ds-test/test.sol";
import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "../src/improvedNFT.sol";

contract improvedNFTTest is Test {
    using stdStorage for StdStorage;

    Vm private vm = Vm(HEVM_ADDRESS);
    improvedNFT private improvednft;
    StdStorage private stdstore;

    function setUp() public {
        // Deploy contract
        improvednft = new improvedNFT("improved_NFT", "iNFT", "baseUri");
    }

    function testFailNoMintPricePaid() public {
        improvednft.mintTo(address(1));
    }

    function testMintPricePaid() public {
        improvednft.mintTo{value: 0.08 ether}(address(1));
    }

    function testFailMaxSupplyReached() public {
        uint256 slot = stdstore
            .target(address(improvednft))
            .sig("currentTokenId()")
            .find();
        bytes32 loc = bytes32(slot);
        bytes32 mockedCurrentTokenId = bytes32(abi.encode(10_000));
        // improvednft.currentTokenId = improvednft.TOTAL_SUPPLY;
        vm.store(address(improvednft), loc, mockedCurrentTokenId);
        improvednft.mintTo{value: 0.08 ether}(address(1));
    }

    function testFailMintZeroAddress() public {
        improvednft.mintTo{value: 0.08 ether}(address(0));
    }

    function testNewMintOwnerRegistered() public {
        improvednft.mintTo{value: 0.08 ether}(address(1));
        uint256 slotOfNewOwner = stdstore
            .target(address(improvednft))
            .sig(improvednft.ownerOf.selector)
            .with_key(1)
            .find();
        // bytes32 locOfNewOwner = bytes32(slotOfNewOwner);
        uint160 ownerOfTokenIdOne = uint160(
            uint256(vm.load(address(improvednft), bytes32(abi.encode(arg))))
        );
        // );
        // bytes32 mockedNewOwner = bytes32(abi.encode(10_000));
        assertEq(address(ownerOfTokenIdOne, address(1)));
    }

    function testBalanceIncremented() public {
        improvednft.mintTo{value: 0.08 ether}(address(1));
        uint256 slotBalance = stdstore
            .target(address(improvednft))
            .sig(improvednft.balanceOf.selector)
            .with_key(address(1))
            .find();
        uint256 balanceFirstMint = uint256(
            vm.load(address(improvednft), bytes32(slotBalance))
        );
        assertEq(balanceFirstMint, 1);

        improvednft.mintTo{value: 0.08 ether}(address(1));
        uint256 balanceSecondMint = uint256(
            vm.load(address(improvednft), bytes32(slotBalance))
        );
        assertEq(balanceSecondMint, 2);

    }

    function testExample() public {
        assertTrue(true);
    }
}
