// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {BaseAccount, IEntryPoint, UserOperation} from "@account-abstraction/contracts/core/BaseAccount.sol";
import {TokenReceivers} from "./TokenReceivers.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract AutoPilot is BaseAccount, TokenReceivers, Initializable {
    using ECDSA for bytes32;
    IEntryPoint private immutable _entryPoint;

    // explicit sizes of nonce, to fit a single storage cell with "bot", not owner since bot is primary user for this account type
    uint96 private _nonce;
    address public bot;
    address public owner;

    struct CallProperties {
        bool allowed; // 1
        uint96 timegap; // 12
        uint128 lastCallTime; // 16
    }

    mapping(bytes32 => CallProperties) public allowedCalls;

    address public temp; // todo : optimize by using calldata instead, calldata should have senders address, and verify that in validateSignature

    constructor(IEntryPoint anEntryPoint, address anOwner) {
        _entryPoint = anEntryPoint;
        owner = anOwner;
        _disableInitializers();
    }

    function initialize(address anOwner) public virtual initializer {
        owner = anOwner;
    }

    /*//////////////////////////////////////////////////////////////
                         EXECUTE 
    //////////////////////////////////////////////////////////////*/

    /**
     * execute a transaction (called directly from owner, or by entryPoint)
     */
    function execute(
        address dest,
        uint256 value,
        bytes calldata func
    ) external {
        _requireFromEntryPointOrOwner();
        if (temp == bot && bot != address(0)) _botCheck(dest, value, func);
        _call(dest, value, func);

        temp = address(0);
    }

    /**
     * execute a sequence of transactions
     */
    function executeBatch(
        address[] calldata dest,
        bytes[] calldata func
    ) external {
        _requireFromEntryPointOrOwner();
        require(dest.length == func.length, "wrong array lengths");

        if (temp == bot && bot != address(0)) {
            for (uint256 i = 0; i < dest.length; i++) {
                _botCheck(dest[i], 0, func[i]);
                _call(dest[i], 0, func[i]); // @audit why AA sample did not consider value for batch? is there any security issue with that?
            }
        } else {
            for (uint256 i = 0; i < dest.length; i++) {
                _call(dest[i], 0, func[i]); // @audit why AA sample did not consider value for batch? is there any security issue with that?
            }
        }

        temp = address(0);
        // dev : do we want to support it like do x+1 action depending upon output of xth action?
    }

    // Require the function call went through EntryPoint or owner
    function _requireFromEntryPointOrOwner() internal view {
        require(
            msg.sender == address(entryPoint()) || msg.sender == owner,
            "account: not Owner or EntryPoint"
        );
    }

    function _botCheck(
        address dest,
        uint256 value,
        bytes calldata func
    ) internal {
        require(dest != address(this), "account: bot self call not allowed"); // a safety measure, to avoid bot calling methods with onlyOwner

        bytes32 hash = keccak256(abi.encode(dest, value, func)); // todo : is encodePacked safe here?
        CallProperties memory props = allowedCalls[hash];
        require(props.allowed, "account: call not allowed");
        require(
            block.timestamp - props.lastCallTime >= props.timegap,
            "account: timegap not reached"
        );
        allowedCalls[hash].lastCallTime = uint128(block.timestamp);
    }

    function _call(address target, uint256 value, bytes memory data) internal {
        (bool success, bytes memory result) = target.call{value: value}(data);
        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                    BASE ACCOUNT OVERRIDES
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc BaseAccount
    function nonce() public view virtual override returns (uint256) {
        return _nonce;
    }

    /// @inheritdoc BaseAccount
    function entryPoint() public view virtual override returns (IEntryPoint) {
        return _entryPoint;
    }

    /// implement template method of BaseAccount
    function _validateAndUpdateNonce(
        UserOperation calldata userOp
    ) internal override {
        require(_nonce++ == userOp.nonce, "account: invalid nonce");
    }

    /// implement template method of BaseAccount
    function _validateSignature(
        UserOperation calldata userOp,
        bytes32 userOpHash
    ) internal virtual override returns (uint256 validationData) {
        bytes32 hash = userOpHash.toEthSignedMessageHash();
        address signer = hash.recover(userOp.signature);
        if (signer == owner || signer == bot) {
            temp = signer;
            return 0;
        }
        return SIG_VALIDATION_FAILED;
    }

    /*//////////////////////////////////////////////////////////////
                    ACCOUNT MANAGEMENT
    //////////////////////////////////////////////////////////////*/

    /**
     * Bot shouldn't be able to call any of following functions
     */
    // callHash = keccak256(abi.encode(dest, value, func));
    function addAllowedCall(bytes32 callHash, uint96 timegap) public onlyOwner {
        // todo: add method for multiple calls
        allowedCalls[callHash] = CallProperties(true, timegap, 0);
    }

    function removeAllowedCall(bytes32 callHash) public onlyOwner {
        allowedCalls[callHash] = CallProperties(false, 0, 0);
    }

    function setBot(address newBot) public onlyOwner {
        bot = newBot;
    }

    modifier onlyOwner() {
        //directly from EOA owner, or through the account itself (which gets redirected through execute())
        require(
            msg.sender == owner || msg.sender == address(this),
            "only owner"
        ); // todo: make requires of same type
        _;
    }

    /*//////////////////////////////////////////////////////////////
                    DEPOSIT MANAGEMENT
    //////////////////////////////////////////////////////////////*/

    /**
     * check current account deposit in the entryPoint
     */
    function getDeposit() public view returns (uint256) {
        return entryPoint().balanceOf(address(this)); // @audit ???? I am not clear on functions of deposit management
    }

    /**
     * deposit more funds for this account in the entryPoint
     */
    function addDeposit() public payable {
        entryPoint().depositTo{value: msg.value}(address(this));
    }

    /**
     * withdraw value from the account's deposit
     * @param withdrawAddress target to send to
     * @param amount to withdraw
     */
    function withdrawDepositTo(
        address payable withdrawAddress,
        uint256 amount
    ) public onlyOwner {
        entryPoint().withdrawTo(withdrawAddress, amount);
    }
}
