// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

//current gas = 470823
contract GasContract {
    error GasContract__Error();

    mapping(address => uint256) public balances;
    mapping(address => uint256) public whitelist;
    mapping(address => ImportantStruct) private whiteListStruct;

    struct ImportantStruct {
        uint256 amount;
        bool paymentStatus;
    }

    address[5] public administrators;

    event WhiteListTransfer(address indexed);
    event AddedToWhitelist(address userAddress, uint256 tier);

    constructor(address[] memory _admins, uint256 _totalSupply) {
        balances[msg.sender] = _totalSupply;
        assembly {
            for {
                let i := 0
            } lt(i, 5) {
                i := add(i, 1)
            } {
                sstore(add(3, i), mload(add(add(_admins, 0x20), mul(0x20, i))))
            }
        }
    }

    function transfer(address _recipient, uint256 _amount, string calldata _name) external {
        unchecked {
            balances[msg.sender] -= _amount;
            balances[_recipient] += _amount;
        }
    }

    function whiteTransfer(address _recipient, uint256 _amount) external {
        if (whitelist[msg.sender] != 1) revert GasContract__Error();
        whiteListStruct[msg.sender] = ImportantStruct(_amount, true);
        unchecked {
            balances[msg.sender] -= _amount - whitelist[msg.sender];
            balances[_recipient] += _amount - whitelist[msg.sender];
        }

        emit WhiteListTransfer(_recipient);
    }

    function addToWhitelist(address _userAddrs, uint256 _tier) external {
        if (_tier >= 255 || !checkForAdmin(msg.sender)) revert GasContract__Error();
        whitelist[_userAddrs] = 1;

        emit AddedToWhitelist(_userAddrs, _tier);
    }

    function balanceOf(address _user) external view returns (uint256) {
        return balances[_user];
    }

    function checkForAdmin(address _user) public view returns (bool admin) {
        assembly {
            for {
                let i := 0
            } lt(i, 5) {
                i := add(i, 1)
            } {
                if eq(sload(add(3, i)), _user) {
                    admin := true
                }
            }
        }
    }

    function getPaymentStatus(address sender) external view returns (bool, uint256) {
        return (whiteListStruct[sender].paymentStatus, whiteListStruct[sender].amount);
    }
}

// Team: 0x8