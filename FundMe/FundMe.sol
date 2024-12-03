// get Funds form users
// Withdraw funds
// Set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import { PriceConveter } from "./PriceConverter.sol";

error NotOwner(); // Custom error to make contract more gas efficent

contract FundMe{
    using PriceConveter for uint256;
    
    uint256 public constant MINIMUM_USD = 5e18;
    //21,415 gas - constant
    //23,515 gas - non-constant

    address public immutable i_owner;
    //21,508 gas - immutable
    //23,644 gas - non-immutable

    constructor(){
        i_owner = msg.sender;
    }

    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

    function fund() public payable {
        // require(msg.value >= 1e18, "Didn't see enough ETH"); //1e18 = 1000000000000000000 wei == 1Etherem;
        require(msg.value.getConversionRate() >= MINIMUM_USD,"Didn't have enough USD");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }


    // Here "onlyOwner work as a middleware this function has to pass that modifier condition"
    function withdraw() public onlyOwner{
        // require(msg.sender == owner, "Must be owner!! request only");
        // for loop
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        funders = new address[](0);

        // payable(msg.sender).transfer(address(this).balance);
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess,"send Failed"); //This need to be true

        (bool callSucess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSucess, "Call failed");
    }

    modifier onlyOwner(){
        // require(msg.sender == i_owner,"Sender is must be owner!!");
        // require(msg.sender == i_owner,NotOwner());
        if(msg.sender != i_owner){ revert NotOwner();} //use cusrtom error to make contract more gas efficent
        _;
    }

    // What happens if someone sends this contract ETH without calling the fund receive() will work

    receive() external payable { 
        fund();
    }

    fallback() external payable { 
        fund();
    }
}