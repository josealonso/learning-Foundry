// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import "../lib/ds-test/src/test.sol";
// import "../lib/forge-std/src/std-lib.sol";
import "../lib/forge-std/src/Test.sol";
import "../src/improvedNFT.sol";
import "./interfaces/HEVM.sol";

contract improvedNFTTest is
    Test // DSTest
{
    using stdStorage for StdStorage;
    // It's declared in Test.sol like that
    // Vm public constant vm = Vm(HEVM_ADDRESS);
    // Hevm private vm = Hevm(HEVM_ADDRESS);
    improvedNFT private improvednft;

    // StdStorage private stdstore; // It's declared in Test.sol

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
        uint160 ownerOfTokenIdOne = uint160(
            uint256(
                vm.load(
                    address(improvednft),
                    bytes32(abi.encode(slotOfNewOwner))
                )
            )
        );
        assertEq(address(ownerOfTokenIdOne), address(1));
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

    function testSafeContractReceiver() public {
        Receiver receiver = new Receiver();
        improvednft.mintTo{value: 0.08 ether}(address(receiver));
        uint256 slotBalance = stdstore
            .target(address(improvednft))
            .sig(improvednft.balanceOf.selector)
            .with_key(address(receiver))
            .find();

        uint256 balance = uint256(
            vm.load(address(improvednft), bytes32(slotBalance))
        );
        assertEq(balance, 1);
    }

    function testFailUnSafeContractReceiver() public {
        vm.etch(address(1), bytes("mock code"));
        improvednft.mintTo{value: 0.08 ether}(address(1));
    }

    function testWithdrawalWorksAsOwner() public {
        // Mint an NFT, sending eth to the contract
        Receiver receiver = new Receiver();
        address payable payee = payable(address(0x1337));
        uint256 priorPayeeBalance = payee.balance;
        improvednft.mintTo{value: improvednft.MINT_PRICE()}(address(receiver));
        // Check that the balance of the contract is correct
        assertEq(address(improvednft).balance, improvednft.MINT_PRICE());
        uint256 nftBalance = address(improvednft).balance;
        // Withdraw the balance and assert it was transferred
        improvednft.withdrawPayments(payee);
        assertEq(payee.balance, priorPayeeBalance + nftBalance);
    }

    function testWithdrawalFailsAsNotOwner() public {
        // Mint an NFT, sending eth to the contract
        Receiver receiver = new Receiver();
        improvednft.mintTo{value: improvednft.MINT_PRICE()}(address(receiver));
        // Check that the balance of the contract is correct
        assertEq(address(improvednft).balance, improvednft.MINT_PRICE());
        // Confirm that a non-owner cannot withdraw
        vm.expectRevert("Ownable: caller is not the owner");
        vm.startPrank(address(0xd3ad));
        improvednft.withdrawPayments(payable(address(0xd3ad)));
        vm.stopPrank();
    }
}

contract Receiver is ERC721TokenReceiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 id,
        bytes calldata data
    ) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
