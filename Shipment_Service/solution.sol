// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ShipmentService {

    address public owner;
    mapping(address => uint256) private countOfProduct;
    mapping(address => uint256) private userPin;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "You are not authorized");
        _;
    }

    //This function inititates the shipment
    /// @dev Initiates the shipment for a customer with a specified PIN.
    /// @param customerAddress The address of the customer.
    /// @param pin The OTP (One-Time Password) for the shipment.
    /// @notice Only the owner of the contract can call this function.
    function shipWithPin(address customerAddress, uint pin) public onlyOwner {
        require(customerAddress != address(0), "customer address is not valid");
        require((pin > 999 && pin < 10000), "Invalid OTP");
        require(customerAddress != owner, "owner cannot buy product");
        require(userPin[customerAddress] < 2, "previous order has not been completed");
        userPin[customerAddress] = pin;
    }

    //This function acknowlegdes the acceptance of the delivery
    /// @dev Acknowledges the acceptance of the delivery by a customer.
    /// @param pin The OTP provided by the customer for their order.
    /// @notice This function can be called by any address.
    function acceptOrder(uint pin) public {
        require(userPin[msg.sender] == pin, "order not placed");
        userPin[msg.sender] = 1;
        countOfProduct[msg.sender]++;
    }

    ///This function outputs the status of the delivery
    /// @dev Checks the status of a delivery for a specific customer.
    /// @param customerAddress The address of the customer whose delivery status is being checked.
    /// @return deliveryStatus A string indicating the current status of the delivery.
    /// @notice This function can be called by the owner of the contract or the customer.
    function checkStatus(address customerAddress) public view returns (string memory deliveryStatus){
        require((customerAddress == msg.sender || msg.sender == owner), "You are not eligible for check product status");
        uint256 pinStatus = userPin[customerAddress];
        if(pinStatus == 0) {
            return "no orders placed";
        } else {
            return pinStatus == 1 ?  "delivered" : "shipped";
        }
    }

    //This function outputs the total number of successful deliveries
    /// @dev Retrieves the total number of successful deliveries for a specific customer.
    /// @param customerAddress The address of the customer whose delivery count is being retrieved.
    /// @return The total number of successful deliveries.
    /// @notice This function can be called by the owner of the contract or the customer.
    function totalCompletedDeliveries(address customerAddress) public view returns (uint) {
        require((customerAddress == msg.sender || msg.sender == owner), "You are not eligible for check product count");
        return countOfProduct[customerAddress];
    }
}